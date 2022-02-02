# frozen_string_literal: true

require "spec_helper"
require "rake"

describe "ingest rake task" do
  before do
    Rake.application.rake_require "tasks/ingest"
    Rake::Task.define_task(:environment)

    allow(CentralizedMetadata::Indexer).to receive(:ingest)
  end

  context "without rake arg" do
    # One or the other context is failing but do to rspec/rake interaction. 
    xit "invokes CentralizedMetadata::Indexer.index" do
      expect(CentralizedMetadata::Indexer).to receive(:ingest)
      Rake.application.invoke_task "db:ingest[foo]"
    end
  end

  context "with rake arg" do
    it "invokes CentralizedMetadata::Indexer.index(foo)" do
      expect(CentralizedMetadata::Indexer).to receive(:ingest).with("foo")
      Rake.application.invoke_task "db:ingest[foo]"
    end
  end
end
