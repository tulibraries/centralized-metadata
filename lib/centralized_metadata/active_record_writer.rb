require "traject"
require "traject/util"
require "traject/indexer/settings"

require "thread"

class CentralizedMetadata::ActiveRecordWriter
    
    # Active record model used for creating or updating records.
    attr_reader :model

    def initialize(argSettings)
      @settings = Traject::Indexer::Settings.new(argSettings)


      unless @settings["active_record.model"]
        raise ArgumentError, "setting `active_record.model` is required"
      end

      @model = @settings["active_record.model"]

      # How many threads to use for the writer?
      # if our thread pool settings are 0, it'll just create a null threadpool that
      # executes in calling context. Default to 1, for waiting on DB I/O. 
      @thread_pool_size = (@settings["sequel_writer.thread_pool"] || 1).to_i

      @batch_size       = (@settings["sequel_writer.batch_size"] || 100).to_i

      @batched_queue         = Queue.new
      # TODO: Update to use Rails concurrency specific tooling.
      # (Not necessary if we keep this single threaded).
      # Maybe not necessary at all?
      @thread_pool = Traject::ThreadPool.new(@thread_pool_size)

      @after_send_batch_callbacks = Array(@settings["active_record.after_send_batch"] || [])

      @internal_delimiter = @settings["active_record.internal_delimiter"] || ","
    end

    # Get the logger from the settings, or default to an effectively null logger
    def logger
      @settings["logger"] ||= Rails.logger 
    end

    def put(context)
      @thread_pool.raise_collected_exception!

      @batched_queue << context
      if @batched_queue.size >= @batch_size
        batch = Traject::Util.drain_queue(@batched_queue)
        @thread_pool.maybe_in_thread_pool(batch) {|batch_arg| send_batch(batch_arg) }
      end
    end

    def close
      @thread_pool.raise_collected_exception!

      # Finish off whatever's left. Do it in the thread pool for
      # consistency, and to ensure expected order of operations, so
      # it goes to the end of the queue behind any other work.
      batch = Traject::Util.drain_queue(@batched_queue)
      @thread_pool.maybe_in_thread_pool(batch) {|batch_arg| send_batch(batch_arg) }
      

      # Wait for shutdown, and time it.
      logger.debug "#{self.class.name}: Shutting down thread pool, waiting if needed..."
      elapsed = @thread_pool.shutdown_and_wait
      if elapsed > 60
        logger.warn "Waited #{elapsed} seconds for all threads, you may want to increase sequel_writer.thread_pool (currently #{@settings["solr_writer.thread_pool"]})"
      end
      logger.debug "#{self.class.name}: Thread pool shutdown complete"

      # check again now that we've waited, there could still be some
      # that didn't show up before.
      @thread_pool.raise_collected_exception!
    end

    def send_batch(batch)
      records = batch.collect do |context|
        record = context.output_hash
        { id: record["id"].join(""), value: record }
      end

      begin
        model.create(records)

      rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
        # Try deleting the old records but keeping non non 'value' fields.
        # TODO: consider putting this in a transaction.
        ids = records.map { |r| r[:id] }
        model.delete(ids)

        # TODO: save old local fields (or should we move those fields to their own table.
        model.create(records)

      rescue => batch_exception
        # TODO: Is this needed anymore?  We're not in a Solr context.
        puts batch_exception
        logger.warn("ActiveRecordWriter: error (#{batch_exception}) inserting batch of #{records.count} starting from system_id #{records.first['system_id']}, retrying individually...")

        records.each do |record|
          send_single(context)
        end
      end

      @after_send_batch_callbacks.each do |callback|
        callback.call(batch, self)
      end
    end

    def send_single(record)      
      r = model.where(id: record["id"].join(""))
      model.create_or_update(id: record["id"].joing(""), value: record )
    end

    def after_send_batch(&block)
      @after_send_batch_callbacks << block
    end
end

