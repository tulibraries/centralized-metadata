# frozen_string_literal: true

require "traject"
require "centralized_metadata"

RSpec.describe "Traject configuration" do
  let(:indexer) { Traject::Indexer::MarcIndexer.new }
  let(:record) do
    MARC::Record.new_from_hash({
      "leader"=>"          22        4500", 
      "fields"=>[{"008"=>"901211nnfacvnnaabn n aaa"}]
      })
  end
  

  before do
    indexer.load_config_file("lib/centralized_metadata/indexer_config.rb")
  end

  describe "field cm_id" do

    context "record has spaces in id field" do
      let(:record) { MARC::Record.new_from_hash("fields"  => [{ "001" => " n  foo   bar  ", "008" => "901211nnfacvnnaabn n aaa" }]) }

      it "removes the all the spaces from the cm_id field" do
        expect(indexer.map_record(record)["cm_id"]).to eq([ "nfoobar" ])
      end
    end
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

  describe "check that spec with single subfield splits" do

    context "385a field with one subfield a" do
      it "output single cm_audience_characteristics instance" do
        record.append(MARC::DataField.new("385", nil, nil, ["a", "Lawyers"]))
        expect(indexer.map_record(record)["cm_audience_characteristics"].count).to eq(1)
      end
    end
    
    context "385a field with two subfield a" do
      it "output two cm_audience_characteristics field instance" do
        record.append(MARC::DataField.new("385", nil, nil, ["a", "Lawyers"], ["a", "Judges"]))
        expect(indexer.map_record(record)["cm_audience_characteristics"].count).to eq(2)
      end
    end
  end
end
