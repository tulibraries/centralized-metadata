# frozen_string_literal: true

require "centralized_metadata"
require "rails_helper"

RSpec.describe CentralizedMetadata::Indexer do
  let (:indexer) { instance_double("Traject::Indexer::MarcIndexer") }
  let (:file) { instance_double(File) }

  describe "ingest" do
    before(:example) do
      allow(Traject::Indexer::MarcIndexer).to receive(:new).and_return(indexer)
      allow(indexer).to receive_messages(load_config_file: "", process: "")
      allow(CentralizedMetadata::Indexer).to receive_messages(open: file)
    end

    context "When filepath is passed in with no extra options" do
      after(:example) do
        CentralizedMetadata::Indexer.ingest("/path/to/file/myfile.mrc")
      end

      it "loads indexer" do
        expect(indexer).to receive(:load_config_file)
      end

      it "sets the filename in indexer settings" do
        expect(Traject::Indexer::MarcIndexer).to receive(:new).with(satisfy do |settings|
          expect(settings[:filename]).to eq("myfile.mrc")
        end)
      end
    end


    context "when we add an overriding filename via the options" do
      after(:example) do
        CentralizedMetadata::Indexer.ingest("/path/to/file/myfile.mrc", original_filename: "my_orignal_file.mrc")
      end

      it "sets the original_filename inside the indexer settings" do
        expect(Traject::Indexer::MarcIndexer).to receive(:new).with(satisfy do |settings|
          expect(settings[:filename]).to eq("myfile.mrc")
          expect(settings[:original_filename]).to eq("my_orignal_file.mrc")
        end)
      end
    end
  end
end
