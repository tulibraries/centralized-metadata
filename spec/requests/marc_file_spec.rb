require "rails_helper"
require "swagger_helper"

RSpec.describe "MarcFile", type: :request do

  path "/marc_file/delete" do

    post("Delete matching records") do
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

      description "This endpoint deletes records in the database that match records in the posted marc file."

      response(422, "unsuccessful") do
        let(:marc_file) { Rack::Test::UploadedFile.new(Rails.root.join("./spec/spec_helper.rb")) }
        run_test!
      end

      response(200, "successful") do

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

          run_test! do | response|

            data = JSON.parse(response.body)
            expect(data.first["cm_id"]).to eq(["2043308"])
          end
        end
      end
    end
  end

  path "/marc_file/ids" do

    post("Get record ids") do
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

      description "This endpoint processes a posted marc file and returns the ids of the records defined in the marc file."

      response(422, "unsuccessful") do
        let(:marc_file) { Rack::Test::UploadedFile.new(Rails.root.join("./spec/spec_helper.rb")) }
        run_test!
      end

      response(200, "successful") do


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

