require "rails_helper"
require "swagger_helper"

RSpec.describe "MarcFile", type: :request do

  path "/marc_file/delete" do

    post("delete records using MARC file") do
      tags "marc_file"
      consumes  "multipart/form-data"
      produces "application/json"

      parameter name: :marc_file, in: :formData, schema: {
        type: :object,
        properties: {
          marc_file: { type: :string, format: :binary },
          kind: { type: :string }
        }
      }

      description "This web service deletes records in the Centralized Metadata Repository that match records from the posted MARC file."

      response(422, "unsuccessful") do
        let(:marc_file) { Rack::Test::UploadedFile.new(Rails.root.join("./spec/spec_helper.rb")) }
        run_test!

        it "returns a json with the error message" do
          data = JSON.parse(response.body)
          expect(data).to eq("invalid record length: requi")
        end
      end

      response(200, "successful") do

        header "X-CM-Records-Processed-Count", schema: { type: :integer }, description: "The number of records processed."
        header "X-CM-Total-Records-Count", schema: { type: :integer }, description: "The total number of records int the database."

        schema "$ref" => "#/components/schemas/Records"

        context "A marc file is provided" do
          let(:marc_file) { Rack::Test::UploadedFile.new(Rails.root.join("./spec/fixtures/marc/louis_armstrong.mrc")) }

          before do
            Record.new(
              id: "2043308",
              value: {
                "cm_id"=>["2043308"],
                "cm_pref_label"=>["Armstrong, Louis, 1901-1971. prf"],
                "cm_import_method"=>["MARC binary"],
                "cm_type"=>["personal name"],
                "cm_see_also"=>
              ["Biographical and program var_labels by Stanley Dance ([2] p. : 1 port.) in container; personnel and original issue and matrix no. on container.",
               "Louis Armstrong, trumpet and vocals, and his band."],
              }).save!
          end

          run_test!

          it "returns a list of deleted records" do
            data = JSON.parse(response.body)
            expect(data.first["cm_id"]).to eq(["2043308"])
          end

          it "deletes the records posted" do
            records = Record.find_by(id: "20433038")
            expect(records).to be_nil
          end
        end
      end
    end
  end

  path "/marc_file/ids" do

    post("retrieve record ids from MARC file") do
      tags "marc_file"

      consumes  "multipart/form-data"
      produces "application/json"

      parameter name: :marc_file, in: :formData, schema: {
        type: :object,
        properties: {
          marc_file: { type: :string, format: :binary },
          kind: { type: :string }
        }
      }

      description "This web service processes a posted MARC file and returns the ids of the records defined in the MARC file."

      response(422, "unsuccessful") do
        let(:marc_file) { Rack::Test::UploadedFile.new(Rails.root.join("./spec/spec_helper.rb")) }
        run_test!
      end

      response(200, "successful") do
        schema type: :array, items: { type: :string }
        context "A marc file is provided" do
          let(:marc_file) { Rack::Test::UploadedFile.new(Rails.root.join("./spec/fixtures/marc/louis_armstrong.mrc")) }

          run_test! do | response|
            data = JSON.parse(response.body)
            expect(data).to eq(["2043308"])
          end
        end
      end
    end
  end

end

