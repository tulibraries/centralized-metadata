# frozen_string_literal: true

require "traject"
require "centralized_metadata"

RSpec.describe "Traject configuration" do
  let(:indexer) { Traject::Indexer::MarcIndexer.new }
  let(:record) { MARC::Record.new }

  before do
    indexer.load_config_file("lib/centralized_metadata/indexer_config.rb")
  end

  describe "field cm_original_key" do

    context "384a does not exist" do
      it "does not extract 384a field" do
        expect(indexer.map_record(record)["cm_original_key"]).to be_nil
      end
    end

    context "384a exists with indicator1 is '0'" do
      it "extracts the 384a subfield value" do
        record.append(MARC::DataField.new("384", "0", nil, ["a", "D major"]))
        expect(indexer.map_record(record)["cm_original_key"]).to eq(["D major"])
      end
    end

    context "384a exists with indicator1 is ' '" do
      it "extracts the 384a subfield value" do
        record.append(MARC::DataField.new("384", " ", nil, ["a", "D major"]))
        expect(indexer.map_record(record)["cm_original_key"]).to eq(["D major"])
      end
    end

    context "384a exists with indicator1 is '1'" do
      it "does not extract 384a field" do
        expect(indexer.map_record(record)["cm_original_key"]).to be_nil
      end
    end
  end

  describe "field cm_work_time_creation" do

    context "388a does not exist" do
      it "does not extract 388a field" do
        expect(indexer.map_record(record)["cm_work_time_creation"]).to be_nil
      end
    end

    context "388a exists with indicator1 is '1'" do
      it "extracts the 388a subfield value" do
        record.append(MARC::DataField.new("388", "1", nil, ["a", "Ancient period"]))
        expect(indexer.map_record(record)["cm_work_time_creation"]).to eq(["Ancient period"])
      end
    end

    context "388a exists with indicator1 is ' '" do
      it "extracts the 388a subfield value" do
        record.append(MARC::DataField.new("388", " ", nil, ["a", "Ancient period"]))
        expect(indexer.map_record(record)["cm_work_time_creation"]).to eq(["Ancient period"])
      end
    end

    context "388a exists with indicator1 is '0'" do
      it "does not extract 388a field" do
        expect(indexer.map_record(record)["cm_work_time_creation"]).to be_nil
      end
    end
  end
end
