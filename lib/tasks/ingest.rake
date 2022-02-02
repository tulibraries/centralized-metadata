# frozen_string_literal: true

require "centralized_metadata"

namespace :db do
  desc "ingest marc records"
  task :ingest, [:filepath] => :environment do |t, args|
    CentralizedMetadata::Indexer.ingest(args[:filepath])
  end
end
