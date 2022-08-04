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

    context "field 100 indicator 1 is 3 && subfield t does not exist" do
      it "will set type to 'family name'" do
        record.append(MARC::DataField.new("100", "3", nil, ["a", "Kennedy"]))
        expect(indexer.map_record(record)["cm_type"]).to eq(["family name"])
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

    context "field 130 exists" do
      it "will set type to 'uniform title work'" do
        record.append(MARC::DataField.new("130", nil, nil, ["a", "Star Trek"]))
        expect(indexer.map_record(record)["cm_type"]).to eq(["uniform title work"])
      end
    end

    context "field 147 exists" do
      it "will set type to 'named event'" do
        record.append(MARC::DataField.new("147", nil, nil, ["a", "Stock Market Crash"]))
        expect(indexer.map_record(record)["cm_type"]).to eq(["named event"])
      end
    end

    context "field 148 exists" do
      it "will set type to 'chronological term'" do
        record.append(MARC::DataField.new("148", nil, nil, ["a", "1863"]))
        expect(indexer.map_record(record)["cm_type"]).to eq(["chronological term"])
      end
    end

    context "field 150 exists" do
      it "will set type to 'topical subject'" do
        record.append(MARC::DataField.new("150", nil, nil, ["a", "Geology"]))
        expect(indexer.map_record(record)["cm_type"]).to eq(["topical subject"])
      end
    end

    context "field 151 exists" do
      it "will set type to 'geographic subject'" do
        record.append(MARC::DataField.new("151", nil, nil, ["a", "Great Lakes"]))
        expect(indexer.map_record(record)["cm_type"]).to eq(["geographic subject"])
      end
    end

    context "field 155 exists" do
      it "will set type to 'genre'" do
        record.append(MARC::DataField.new("155", nil, nil, ["a", "Cartoon"]))
        expect(indexer.map_record(record)["cm_type"]).to eq(["genre"])
      end
    end
  end  

  describe "extract_see_also" do
    before(:each) do
      indexer.configure do
        to_field "cm_see_also", extract_see_also
      end
    end

    context "field 500 exists and subfield w does not exist" do
      it "will extract 500" do
        record.append(MARC::DataField.new("500", nil, nil, ["a", "Daniels, Michael J."]))
        expect(indexer.map_record(record)["cm_see_also"]).to eq(["Daniels, Michael J."])
      end
    end

    context "field 500 exists and subfield w value starts with g" do
      it "will not extract 500" do
        record.append(MARC::DataField.new("500", nil, nil, ["w", "g"]))
        expect(indexer.map_record(record)["cm_see_also"]).to be_nil
      end
    end

    context "field 500 exists and subfield w value starts with h" do
      it "will not extract 500" do
        record.append(MARC::DataField.new("500", nil, nil, ["w", "h"]))
        expect(indexer.map_record(record)["cm_see_also"]).to be_nil
      end
    end

    context "field 510 exists and subfield w value starts with b and other valid subfields" do
      it "will extract 510 subfield values" do
        record.append(MARC::DataField.new("510", nil, nil, ["w", "b"], ["a", "Missouri"], ["b", "State Highway"]))
        expect(indexer.map_record(record)["cm_see_also"]).to eq(["Missouri State Highway"])
      end
    end
  end

  describe "extract_narrower_term" do
    before(:each) do
      indexer.configure do
        to_field "cm_narrower_term", extract_narrower_term
      end
    end

    context "field 500 exists and subfield w does not exist" do
      it "will not extract 500" do
        record.append(MARC::DataField.new("500", nil, nil, ["a", "Daniels, Michael J."]))
        expect(indexer.map_record(record)["cm_narrower_term"]).to be_nil
      end
    end

    context "field 510 exists and subfield w value starts with h" do
      it "will extract 510" do
        record.append(MARC::DataField.new("510", nil, nil, ["w", "h"], ["a", "Missouri"]))
        expect(indexer.map_record(record)["cm_narrower_term"]).to eq(["Missouri"])
      end
    end

    context "field 510 exists and subfield w value starts with h and other valid subfields" do
      it "will extract 510 subfield values" do
        record.append(MARC::DataField.new("510", nil, nil, ["w", "h"], ["a", "Missouri"], ["b", "State Highway"]))
        expect(indexer.map_record(record)["cm_narrower_term"]).to eq(["Missouri State Highway"])
      end
    end
  end
end
