# frozen_string_literal: true

module RecordsProcessedCountHeader
  extend ActiveSupport::Concern

  included do
    after_action :set_records_processed_count_header, only: [:create, :delete]
  end

  def set_records_processed_count_header
    response.headers["X-CM-Records-Processed-Count"] = @records.count
  end
end
