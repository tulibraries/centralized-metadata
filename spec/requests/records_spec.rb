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
      description "This web service creates a new record. There are two methods for adding records.\n
      Using a curl statement: curl -F 'marc_file=@spec/fixtures/marc/louis_armstrong.mrc' https://centralized-metadata-qa.k8s.temple.edu \n
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

  describe "PATCH/PUT /records/:id" do
    it "updates the values of an individual record" do
      get "/records/2043308"
      record = JSON.parse(response.body)
      record.update("cm_type" => ["Test update"])
      expect(record["cm_type"]).to eq(["Test update"])
    end

    it "updates the values of local metadatum" do
      get "/records/2043308"
      record = JSON.parse(response.body)
      record["local_metadatum"].update("cm_local_note" => ["Changed note"])
      expect(record["local_metadatum"]["cm_local_note"]).to eq(["Changed note"])
    end
  end
end
