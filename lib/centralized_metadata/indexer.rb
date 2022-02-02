# frozen_string_literal: true

require "traject"

class CentralizedMetadata::Indexer

  def self.ingest(filepath)

    filepath ||= ENV["CM_SOURCE"] || ""

    filepath = "./spec/fixtures/marc" if ["yes", "true", true].include?(ENV["CM_USE_FIXTURES"])

    indexer = Traject::Indexer::MarcIndexer.new(
      writer_class_name: "CentralizedMetadata::ActiveRecordWriter",
      "active_record.model": Record,
    )

    indexer.load_config_file("#{File.dirname(__FILE__)}/indexer_config.rb")

    if File.directory?(filepath)
      Dir.glob("#{filepath}/*.mrc").each { |f| indexer.process(f) } 
    elsif File.exist?(filepath)
      indexer.process(filepath)
    end
  end
end
