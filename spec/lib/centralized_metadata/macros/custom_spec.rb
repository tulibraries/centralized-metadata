# frozen_string_literal: true

require "traject"
require "centralized_metadata"


RSpec.describe CentralizedMetadata::Macros::Custom do
  let(:indexer) { Traject::Indexer.new }
  let(:record) { MARC::Record.new }

  before do
    indexer.extend CentralizedMetadata::Macros::Custom
  end


  describe "field cm_original_key" do
    before(:each) do
      indexer.configure  do
        to_field "cm_original_key", extract_original_key
      end
    end

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
end
