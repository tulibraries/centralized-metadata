require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Records", type: :request do
  before do
    file = fixture_file_upload("louis_armstrong.mrc")
    post "/records", params: { marc_file: file }
    record = Record.first
    metadatum = LocalMetadatum.create(cm_local_pref_label: "test_pref")
    note = LocalNote.create(cm_local_note: "test_note")
    variant = LocalVariant.create(cm_local_var_label: "test_var")
    metadatum.local_notes << note
    metadatum.local_variants << variant
    record.local_metadatum = metadatum
  end

  path '/records' do
    get('list records') do
      tags 'records'
      description "This web service returns records in a JSON format. 
      The pagination default is set to return 25 records at a time. If you would like to change this,
      add the parameter per_page=number_desired to the query parameters."
      response(200, 'successful') do        

        let(:record) { JSON.parse(response.body).first }

        before do
          get "/records"
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end
      end
    end

    post('create record') do
      tags 'records'
      consumes  'multipart/form-data'
      produces 'application/json'
      # TODO: Stop using work around when upstream issue is fixed:
      # ref:  https://github.com/rswag/rswag/issues/348
      parameter name: :marc_file, in: :formData, schema: {
        type: :object,
        properties: {
          marc_file: { type: :string, format: :binary },
          kind: { type: :string }
        }
      }

      description "This web service creates a new record. There are two methods for adding records.\n
      Using a curl statement: curl -F 'marc_file=@spec/fixtures/marc/louis_armstrong.mrc' https://centralized-metada
ta-qa.k8s.temple.edu \n
      Ingest with a rake task: rake db:ingest[spec/fixtures/marc]."
      response(200, 'successful') do
        it "returns http success" do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  path '/records/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show record') do
      tags 'records'
      description "This web service returns an indivudual record in JSON format."
      response(200, 'successful') do
        let(:id) { '123' }

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end
      end
    end

    patch('update record') do
      tags 'records'
      description "This web service updates a record."
      response(200, 'successful') do
        let(:id) { '123' }

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end
      end
    end

    put('update record') do
      tags 'records'
      description "This web service updates a record."
      response(200, 'successful') do
        let(:id) { '123' }

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end
      end
    end

    delete('delete record') do
      tags 'records'
      description "This web service deletes a record."
      response(200, 'successful') do
        let(:id) { '123' }

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "GET /records" do
    let(:record) { JSON.parse(response.body).first }

    before do
      get "/records"
    end

    it "gets records that contain a cm_updated_at and cm_created_at value " do
      expect(record).to have_key("cm_created_at")
      expect(record).to have_key("cm_updated_at")
    end

    it "gets records that contain a cm_filename" do
      expect(record).to have_key("cm_filename")
      expect(record["cm_filename"]).to eq(["louis_armstrong.mrc"])
    end
  end

  describe "GET /records/:id" do
    it "gets a record that contains a cm_updated_at and cm_created_at value " do
      get "/records/2043308"
      record = JSON.parse(response.body)
      expect(record).to have_key("cm_created_at")
      expect(record).to have_key("cm_updated_at")
      expect(record.dig("local_metadatum", "cm_local_pref_label")).to eq("test_pref")
      expect(record.dig("local_metadatum", "cm_local_var_label")).to eq(["test_var"])
      expect(record.dig("local_metadatum", "cm_local_note")).to eq(["test_note"])
    end
  end

  describe "PUT /records/:id" do
    before do
      Record.new(
        id: "put-test",
        value: {
          "cm_id"=>["put-test"],
          "cm_pref_label"=>["Armstrong, Louis, 1901-1971. prf"],
          "cm_import_method"=>["MARC binary"],
          "cm_type"=>["personal name"],
          "cm_see_also"=>
        ["Biographical and program notes by Stanley Dance ([2] p. : 1 port.) in container; personnel and original issue and matrix no. on container.",
         "Louis Armstrong, trumpet and vocals, and his band."],
        }.to_json
      ).save!
    end

    after do
      Record.find_by(id: "put-test").destroy!
    end


    context "not sending required field in API call" do
      it "should errror out because we need something to update to" do
        put "/records/put-test"
        expect(response.status).to eq(422)

        data = JSON.parse(body)
        expect(data["params"]).to eq(["param is missing or the value is empty: cm_id"])
      end
    end

    context "not having required cm_id value" do
      let(:payload) { {}.to_json }

      it "should error out because the cm_id value is required" do
        put "/records/put-test", params: payload , headers: { 'Content-Type' => 'application/json' }
        expect(response.status).to eq(422)

        data = JSON.parse(body)
        expect(data["params"]).to eq(["param is missing or the value is empty: cm_id"])
      end
    end

    context "cm_id value is not equal to :id in records/:id path" do
      let(:payload) { { cm_id: ["not-put-test"], cm_type: ["foobar"] }.to_json }

      it "should error out because the value of the cm_id field to be updated should match the path id" do
        put "/records/put-test", params: payload , headers: { 'Content-Type' => 'application/json' }
        expect(response.status).to eq(422)

        data = JSON.parse(body)
        expect(data["cm_id"]).to eq(["The :cm_id and :id values must match."])
      end
    end


    context "A record is sent in as a payload in the request" do
      let(:payload) { { cm_id: ["put-test"], cm_type: ["foobar"] }.to_json }

      it "should completely replace the value or the record in the database with the updated value" do

        put "/records/put-test", params: payload , headers: { 'Content-Type' => 'application/json' }

        expect(response).to be_successful
        data = JSON.parse(body)
        expect(data.except("cm_updated_at", "cm_created_at", "local_metadatum")).to eq(JSON.parse(payload))
      end
    end
  end

  describe "PATCH /records/:id" do
    before do
      Record.new(
        id: "patch-test",
        value: {
          "cm_id"=>["patch-test"],
          "cm_pref_label"=>["Armstrong, Louis, 1901-1971. prf"],
          "cm_import_method"=>["MARC binary"],
          "cm_type"=>["personal name"],
          "cm_see_also"=>
        ["Biographical and program notes by Stanley Dance ([2] p. : 1 port.) in container; personnel and original issue and matrix no. on container.",
         "Louis Armstrong, trumpet and vocals, and his band."],
        }.to_json
      ).save!
    end

    after do
      Record.find_by(id: "patch-test").destroy!
    end

    context "not sending required field in API call" do
      it "should errror out because we need something to update to" do
        put "/records/patch-test"
        expect(response.status).to eq(422)

        data = JSON.parse(body)
        expect(data["params"]).to eq(["param is missing or the value is empty: cm_id"])
      end
    end

    context "not having required cm_id value" do
      let(:payload) { {}.to_json }

      it "should error out because the cm_id value is required" do
        put "/records/patch-test", params: payload , headers: { 'Content-Type' => 'application/json' }
        expect(response.status).to eq(422)

        data = JSON.parse(body)
        expect(data["params"]).to eq(["param is missing or the value is empty: cm_id"])
      end
    end

    context "cm_id value is not equal to :id in records/:id path" do
      let(:payload) { { cm_id: ["not-patch-test"], cm_type: ["foobar"] }.to_json }

      it "should error out because the value of the cm_id field to be updated should match the path id" do
        put "/records/patch-test", params: payload , headers: { 'Content-Type' => 'application/json' }
        expect(response.status).to eq(422)

        data = JSON.parse(body)
        expect(data["cm_id"]).to eq(["The :cm_id and :id values must match."])
      end
    end

    context "A record is sent in as a payload in the request" do
      let(:payload) { { cm_id: ["patch-test"], cm_type: ["foobar"] }.to_json }

      it "should only replace/update the specific fields in the payload" do

        patch "/records/patch-test", params: payload , headers: { 'Content-Type' => 'application/json' }

        expect(response).to be_successful
        data = JSON.parse(body)
        expect(data.except("cm_updated_at", "cm_created_at", "local_metadatum")).to eq({
          "cm_id"=>["patch-test"],
          "cm_pref_label"=>["Armstrong, Louis, 1901-1971. prf"],
          "cm_import_method"=>["MARC binary"],
          "cm_type"=>["foobar"],
          "cm_see_also"=>
        ["Biographical and program notes by Stanley Dance ([2] p. : 1 port.) in container; personnel and original issue and matrix no. on container.",
         "Louis Armstrong, trumpet and vocals, and his band."],
        })
      end
    end
  end
end
