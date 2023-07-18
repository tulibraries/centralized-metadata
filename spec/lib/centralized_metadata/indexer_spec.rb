# frozen_string_literal: true

require "centralized_metadata"
require "rails_helper"

RSpec.describe CentralizedMetadata::Indexer do
  let (:indexer) { instance_double("Traject::Indexer::MarcIndexer") }
  let (:file) { instance_double(File) }

  describe "#fields" do
    it "gets the configured field names" do
      expect(subject.class.fields.first).to eq("cm_id")
    end
  end

  describe "get_indexer" do
    before(:example) do
      allow(Traject::Indexer::MarcIndexer).to receive(:new).and_return(indexer)
      allow(indexer).to receive_messages(load_config_file: "", process: "")
      allow(subject.class).to receive_messages(open: file)
    end

    context "When filepath is passed in with no extra options" do
      after(:example) do
        subject.class.get_indexer("/path/to/file/myfile.mrc")
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
        subject.class.get_indexer("/path/to/file/myfile.mrc", original_filename: "my_orignal_file.mrc")
      end

      it "sets the original_filename inside the indexer settings" do
        expect(Traject::Indexer::MarcIndexer).to receive(:new).with(satisfy do |settings|
          expect(settings[:filename]).to eq("myfile.mrc")
          expect(settings[:original_filename]).to eq("my_orignal_file.mrc")
        end)
      end
    end
  end

  describe "get_records" do
    let(:records) { CentralizedMetadata::Indexer.get_records(filepath) }


    context "given a filepath to a marc records" do
      let(:filepath)  { "./spec/fixtures/marc/louis_armstrong.mrc" }

      it "gets an array of records processed through config file" do
        expect(records).to eq([
          {"cm_id"=>["2043308"],
           "cm_pref_label"=>["Armstrong, Louis, 1901-1971. prf"],
           "cm_import_method"=>["MARC binary"],
           "cm_filename"=>["louis_armstrong.mrc"],
           "cm_type"=>["personal name"],
           "cm_see_also"=>
           ["Biographical and program notes by Stanley Dance ([2] p. : 1 port.) in container; personnel and original issue and matrix no. on container.",
            "Louis Armstrong, trumpet and vocals, and his band."],
            "cm_audience_characteristics"=>["discussion"],
            "cm_characteristics"=>["discussion"],
            "cm_notmusic_format"=>["discussion"]}])
      end
    end

    context "filepath does not exist" do
      let(:filepath) { "file/to/nowhere" }

      it "should fail" do
        expect { records }.to raise_error
      end
    end
  end
end
