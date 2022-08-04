require "rails_helper"
require "centralized_metadata"

RSpec.feature "ViewIngestedRecords", type: :feature do
  before do
    CentralizedMetadata::Indexer.ingest("./spec/fixtures/marc/louis_armstrong.mrc")
  end

  scenario "go to the records page" do
    visit "/records"

    json = JSON.parse(html)
    expect(json.count).to eq(1)
    expect(json.first["cm_id"].join("")).to eq("2043308")
  end

  scenario "go to a specific record" do
    visit "/records/2043308"
    json = JSON.parse(html)
    expect(json["cm_id"].join("")).to eq("2043308")
  end
end
