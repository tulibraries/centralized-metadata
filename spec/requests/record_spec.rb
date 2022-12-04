require 'rails_helper'

RSpec.describe "Records", type: :request do
  before do
    file = fixture_file_upload("louis_armstrong.mrc")
    post "/records", params: { marc_file: file }
  end

  describe "POST /records" do
    it "returns http success" do
      expect(response).to have_http_status(:success)
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
      expect(record.dig("cm_filename")).to eq(["louis_armstrong.mrc"])
    end
  end

  describe "GET /records/:id" do
    it "gets a record that contains a cm_updated_at and cm_created_at value " do
      get "/records/2043308"
      record = JSON.parse(response.body)
      expect(record).to have_key("cm_created_at")
      expect(record).to have_key("cm_updated_at")
    end
  end
end
