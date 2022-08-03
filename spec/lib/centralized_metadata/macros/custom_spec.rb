# frozen_string_literal: true

require "traject"
require "centralized_metadata"


RSpec.describe CentralizedMetadata::Macros::Custom do
  let(:indexer) { Traject::Indexer.new }
  let(:record) { MARC::Record.new }

  before do
    indexer.extend CentralizedMetadata::Macros::Custom
  end


  describe "extract_original_key" do
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


  describe "set_type" do
    before(:each) do
      indexer.configure do
        to_field "cm_type", set_type
      end
    end

    context "field 100 indicator 1 is not 3 && subfield t does not exist" do
      it "will set type to 'personal name'" do
        record.append(MARC::DataField.new("100", "1", nil, ["a", "Kinzer, David"]))
        expect(indexer.map_record(record)["cm_type"]).to eq(["personal name"])
      end
    end

    context "field 110 does not have subfield t" do
      it "will set type to 'corporate name'" do
        record.append(MARC::DataField.new("110", nil, nil, ["a", "Alphabet Inc."]))
        expect(indexer.map_record(record)["cm_type"]).to eq(["corporate name"])
      end
    end

    context "field 111 does not have subfield t" do
      it "will set type to 'conference name'" do
        record.append(MARC::DataField.new("111", nil, nil, ["a", "Rails Conf"]))
        expect(indexer.map_record(record)["cm_type"]).to eq(["conference name"])
      end
    end

    context "field 100 has subfield t" do
      it "will set type to 'name-title work'" do
        record.append(MARC::DataField.new("100", nil, nil, ["t", "Romeo and Juliet"]))
        expect(indexer.map_record(record)["cm_type"]).to eq(["name-title work"])
      end
    end

    context "field 110 has subfield t" do
      it "will set type to 'name-title work'" do
        record.append(MARC::DataField.new("110", nil, nil, ["t", "Romeo and Juliet"]))
        expect(indexer.map_record(record)["cm_type"]).to eq(["name-title work"])
      end
    end

    context "field 111 has subfield t" do
      it "will set type to 'name-title work'" do
        record.append(MARC::DataField.new("111", nil, nil, ["t", "Romeo and Juliet"]))
        expect(indexer.map_record(record)["cm_type"]).to eq(["name-title work"])
      end
    end
  end
end
