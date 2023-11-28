# frozen_string_literal: true

require "traject"

class CentralizedMetadata::Indexer
  INDEXER_CONFIG_FILE =  "#{File.dirname(__FILE__)}/indexer_config.rb"

  def self.ingest(filepath, options = {})
    filepath ||= ENV["CM_SOURCE"] || ""
    filepath = "./spec/fixtures/marc" if ["yes", "true", true].include?(ENV["CM_USE_FIXTURES"])


    records = []

    if File.directory?(filepath)
      Dir.glob("#{filepath}/*").each { |f|
        records += ingest(f, options)
      }
    elsif File.exist?(filepath)
      records += get_records(filepath, options)
    end

    Record.upsert_all(records.map { |r|
      { id: r["cm_id"].join(""), value: r }
    }) unless records.empty?

    records
  end


  def self.get_records(filepath, options={})
    indexer = get_indexer(filepath, options)
    writer = Traject::ArrayWriter.new
    reader = Traject::MarcReader.new(filepath, {})

    indexer.process_with(reader, writer).values
  end

  def self.get_indexer(filepath="", options={})
    options = options.with_indifferent_access
    writer_class_name  = options["writer_class_name"] ||
      "CentralizedMetadata::ActiveRecordWriter"


    indexer = Traject::Indexer::MarcIndexer.new(
      writer_class_name: writer_class_name,
      "active_record.model": Record,
      filename: File.basename(filepath),
      original_filename: options.dig(:original_filename)
    )
    indexer.load_config_file("#{File.dirname(__FILE__)}/indexer_config.rb")
    indexer
  end

  def self.fields
    get_indexer.instance_variable_get(:@index_steps)
      .map(&:field_name)
  end

end
