# frozen_string_literal: true

require "centralized_metadata"
require "rails_helper"

RSpec.describe CentralizedMetadata::Indexer do
  describe "ingest" do
    before(:example) do
      @indexer = instance_double("Traject::Indexer::MarcIndexer")
      file = instance_double(File)

      allow(Traject::Indexer::MarcIndexer).to receive(:new).and_return(@indexer)
      allow(@indexer).to receive_messages(load_config_file: "", process: "")
      allow(CentralizedMetadata::Indexer).to receive_messages(open: file)
    end

    after(:example) do
      CentralizedMetadata::Indexer.ingest(@file)
    end

    it "loads indexer" do
      expect(@indexer).to receive(:load_config_file)
    end
  end
end
