# frozen_string_literal: true

require "traject"

class CentralizedMetadata::Indexer

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

    indexer = Traject::Indexer::MarcIndexer.new(
      writer_class_name: "CentralizedMetadata::ActiveRecordWriter",
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
