# frozen_string_literal: true

require "traject"

class CentralizedMetadata::Indexer
  INDEXER_CONFIG_FILE =  "#{File.dirname(__FILE__)}/indexer_config.rb"

  def self.ingest(filepath, options = {})
    filepath ||= ENV["CM_SOURCE"] || ""
    filepath = "./spec/fixtures/marc" if ["yes", "true", true].include?(ENV["CM_USE_FIXTURES"])

    if File.directory?(filepath)
      Dir.glob("#{filepath}/*.mrc").each { |f|
        get_indexer(filepath, options)
          .process(f)
      }
    elsif File.exist?(filepath)
        get_indexer(filepath, options)
          .process(filepath)
    end
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

  def self.get_records(filepath)
    indexer = get_indexer(filepath)
    writer = Traject::ArrayWriter.new
    reader = Traject::MarcReader.new(filepath, {})

    indexer.process_with(reader, writer).values
  end
end
