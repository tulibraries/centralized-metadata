require 'rails_helper'

RSpec.describe "Records", type: :request do

  describe "POST /records" do
    it "returns http success" do
      file = fixture_file_upload("louis_armstrong.marc")
      post "/records", params: { marc_file: file }
      expect(response).to have_http_status(:success)
    end
  end

end
