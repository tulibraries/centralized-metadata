# frozen_string_literal: true

require "traject"
require "centralized_metadata"
require "rails_helper"


RSpec.describe CentralizedMetadata::Macros::Custom do
  let(:indexer) { Traject::Indexer.new }
  let(:record) do
    MARC::Record.new_from_hash({
      "leader"=>"          22        4500",
      "fields"=>[{"008"=>"901211nnfacvnnaabn n aaa"}]
      })
  end

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

  describe "extract_broader_term" do
    before(:each) do
      indexer.configure do
        to_field "cm_broader_term", extract_broader_term
      end
    end

    context "field 500 exists and subfield w does not exist" do
      it "will not extract 500" do
        record.append(MARC::DataField.new("500", nil, nil, ["a", "Daniels, Michael J."]))
        expect(indexer.map_record(record)["cm_broader_term"]).to be_nil
      end
    end

    context "field 510 exists and subfield w value starts with g" do
      it "will extract 510" do
        record.append(MARC::DataField.new("510", nil, nil, ["w", "g"], ["a", "Missouri"]))
        expect(indexer.map_record(record)["cm_broader_term"]).to eq(["Missouri"])
      end
    end

    context "field 510 exists and subfield w value starts with h and other valid subfields" do
      it "will extract multiple 510 subfield values" do
        record.append(MARC::DataField.new("510", nil, nil, ["w", "g"], ["a", "Wisconsin"], ["b", "State Highway"]))
        expect(indexer.map_record(record)["cm_broader_term"]).to eq(["Wisconsin State Highway"])
      end
    end
  end

  describe "add_source_vocab" do
    before(:each) do
      indexer.configure do
        to_field "cm_source_vocab", add_source_vocab
      end
    end


    context "If 040a is 'DNLM'" do
      it "sets vocab = mesh" do
        record.append(MARC::DataField.new("040", nil, nil, ["a", "DNLM"]))
        expect(indexer.map_record(record)["cm_source_vocab"]).to eq(["mesh"])
      end
    end

    context "If 040e is 'lcmpt'" do
      it "sets vocab = lcmpt" do
        record.append(MARC::DataField.new("040", nil, nil, ["e", "lcmpt"]))
        expect(indexer.map_record(record)["cm_source_vocab"]).to eq(["lcmpt"])
      end
    end

    context "If 040f is 'lcgft'" do
      it "sets vocab = lcgft" do
        record.append(MARC::DataField.new("040", nil, nil, ["f", "lcgft"]))
        expect(indexer.map_record(record)["cm_source_vocab"]).to eq(["lcgft"])
      end
    end

    # 040 $f cases
    context "If 040f is 'gsafd'" do
      it "sets vocab = gsafd" do
        record.append(MARC::DataField.new("040", nil, nil, ["f", "gsafd"]))
        expect(indexer.map_record(record)["cm_source_vocab"]).to eq(["gsafd"])
      end
    end

    context "If 040f is 'rbmscv'" do
      it "sets vocab = rbmscv" do
        record.append(MARC::DataField.new("040", nil, nil, ["f", "rbmscv"]))
        expect(indexer.map_record(record)["cm_source_vocab"]).to eq(["rbmscv"])
      end
    end

    context "If 040f is 'olacvggt'" do
      it "sets vocab = olacvggt" do
        record.append(MARC::DataField.new("040", nil, nil, ["f", "olacvggt"]))
        expect(indexer.map_record(record)["cm_source_vocab"]).to eq(["olacvggt"])
      end
    end

    context "If 040f is 'homoit'" do
      it "sets vocab = homoit" do
        record.append(MARC::DataField.new("040", nil, nil, ["f", "homoit"]))
        expect(indexer.map_record(record)["cm_source_vocab"]).to eq(["homoit"])
      end
    end

    context "If 040f is 'lcdgt'" do
      it "sets vocab = lcdgt" do
        record.append(MARC::DataField.new("040", nil, nil, ["f", "lcdgt"]))
        expect(indexer.map_record(record)["cm_source_vocab"]).to eq(["lcdgt"])
      end
    end

    context "If 040f is 'fast'" do
      it "sets vocab = fast" do
        record.append(MARC::DataField.new("040", nil, nil, ["f", "fast"]))
        expect(indexer.map_record(record)["cm_source_vocab"]).to eq(["fast"])
      end
    end

    # 024 $2 cases
    context "If 0242 is 'aat'" do
      it "sets vocab = aat" do
        record.append(MARC::DataField.new("024", nil, nil, ["2", "aat"]))
        expect(indexer.map_record(record)["cm_source_vocab"]).to eq(["aat"])
      end
    end

    context "If 0242 is 'tgm'" do
      it "sets vocab = tgm" do
        record.append(MARC::DataField.new("024", nil, nil, ["2", "tgm"]))
        expect(indexer.map_record(record)["cm_source_vocab"]).to eq(["tgm"])
      end
    end

    # 008/11 case
    context "If 008/11 is 'a'" do
      let(:record) do
        MARC::Record.new_from_hash({
          "leader"=>"          22        4500",
          "fields"=>[{"008"=>"901211nnfaaannaabn n aaa"}]
          })
      end
      it "sets vocab = lcsh" do
        record.leader = "00000nam a2200000 a 4500"
        expect(indexer.map_record(record)["cm_source_vocab"]).to eq(["lcsh"])
      end
    end
  end

  describe "add_import_method" do
    before(:each) do
      indexer.configure  do
        to_field "cm_import_method", add_import_method
      end
    end

    context "when filename is present" do
      it "will set cm_import_method" do
        indexer.settings[:filename] = "TEUSSUB.060"
        expect(indexer.map_record(record)["cm_import_method"]).to eq(["MARC binary"])
      end
    end

    context "when filename is not present" do
      it "will not set cm_import_method" do
        indexer.settings[:filename] = ""
        expect(indexer.map_record(record)["cm_import_method"]).to be_nil
      end
    end
  end

  describe "add_filename" do
    before(:each) do
      indexer.configure do
        to_field "cm_filename", add_filename
      end
    end

    context "when filename override provided" do
      it "adds the filename override provided" do
        indexer.settings[:filename] = "xxxxxxxxx"
        indexer.settings[:original_filename] = "TEUSSUB.045"
        expect(indexer.map_record(record)["cm_filename"]).to eq(["TEUSSUB.045"])
      end
    end

    context "when only filename provided" do
      it "adds the filename provided" do
        indexer.settings[:filename] = "TEUSSUB.045"
        expect(indexer.map_record(record)["cm_filename"]).to eq(["TEUSSUB.045"])
      end
    end

    context "when neither a filename nor filename override given" do
      it "does not add a cm_filename field" do
        expect(indexer.map_record(record)["cm_filename"]).to be_nil
      end
    end
  end

  describe "extract_marc_subfields" do
    let(:marc_fields) { "383abcde" }

    before do
      without_partial_double_verification do
        allow(indexer).to receive(:marc_fields) { marc_fields }
      end

      indexer.configure do
        to_field "cm_music_num_designation", extract_marc_subfields(marc_fields)
      end
    end

    context "no field 383" do
      it "will not extract 383" do
        expect(indexer.map_record(record)["cm_music_num_designation"]).to be_nil
      end
    end

    context "field 383 subfield a" do
      it "will extract 383a with subfield markup" do
        record.append(MARC::DataField.new("383", nil, nil, ["a", "no. 9"]))
        expect(indexer.map_record(record)["cm_music_num_designation"]).to eq(["$ano. 9"])
      end
    end

    context "field 383 multiple subfields" do
      it "will extract 383 with multiple subfield markup" do
        record.append(MARC::DataField.new("383", nil, nil, ["c", "RV 269"], ["c", "RV 315"], ["c", "RV 293"], ["c", "RV 297"], ["d", "Ryom"]))
        expect(indexer.map_record(record)["cm_music_num_designation"]).to eq(["$cRV 269$cRV 315$cRV 293$cRV 297$dRyom"])
      end
    end

    context "field 383 multiple subfields with excluded subfield" do
      it "will extract 383 $b but not 383 $3" do
        record.append(MARC::DataField.new("383", nil, nil, ["3", "Romances"], ["b", "op. 127"]))
        expect(indexer.map_record(record)["cm_music_num_designation"]).to eq(["$bop. 127"])
      end
    end
  end
end
