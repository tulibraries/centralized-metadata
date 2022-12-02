require "rails_helper"
require "centralized_metadata"

RSpec.feature "ViewIngestedRecords", type: :feature do
  before do
    CentralizedMetadata::Indexer.ingest("./spec/fixtures/marc/louis_armstrong.mrc")
  end

  scenario "go to the records page" do
    visit "/records"

    results = JSON.parse(html)
    expect(results.count).to eq(1)
    expect(results.first["value"]["cm_id"].join("")).to eq("2043308")
  end

  scenario "go to a specific record" do
    visit "/records/2043308"
    object = JSON.parse(html)
    expect(object["value"]["cm_id"].join("")).to eq("2043308")
  end
end
