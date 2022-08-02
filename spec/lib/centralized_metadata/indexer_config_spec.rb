# frozen_string_literal: true

require "traject"
require "centralized_metadata"

RSpec.describe "Traject configuration" do
  let(:indexer) { Traject::Indexer::MarcIndexer.new }
  let(:record) do
    MARC::Record.new_from_hash({
      "leader"=>"          22        4500", 
      "fields"=>[{"008"=>"foo"}]
      })
  end
  

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

  describe "field cm_use_subject" do

    context "008 does not exist" do
      let(:record) { MARC::Record.new }
      it "does not extract 008 field" do
        expect{indexer.map_record(record)["cm_use_subject"]}.to raise_error
      end
    end

    context "008[15] is 'a'" do
      it "cm_use_subject maps with value 'YES'" do
        record["008"].value = "000707n| azannaabn          |a ana      "
        expect(indexer.map_record(record)["cm_use_subject"]).to eq(["YES"])
      end
    end  

    context "008[15] is not 'a'" do
      it "does not map cm_use_subject" do
        record["008"].value = "000707n| azannabbn          |a ana      "
        expect(indexer.map_record(record)["cm_use_subject"]).to be_nil
      end
    end
  end

  describe "field cm_undiff_name" do

    context "008 does not exist" do
      let(:record) { MARC::Record.new }
      it "does not extract 008 field" do
        expect{indexer.map_record(record)["cm_undiff_name"]}.to raise_error
      end
    end

    context "008[32] is 'b'" do
      it "cm_undiff_name maps with value 'YES'" do
        record["008"].value = "000707n| azannaabn          |a aba      "
        expect(indexer.map_record(record)["cm_undiff_name"]).to eq(["YES"])
      end
    end
    
    context "008[32] is not 'b'" do
      it "does not map cm_undiff_name" do
        record["008"].value = "000707n| azannaabn          |a ana      "
        expect(indexer.map_record(record)["cm_undiff_name"]).to be_nil
      end
    end
  end
end
