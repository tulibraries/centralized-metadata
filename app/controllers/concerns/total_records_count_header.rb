# frozen_string_literal: true

module TotalRecordsCountHeader
  extend ActiveSupport::Concern

  included do
    after_action :set_total_records_count_header, only: [:create, :destroy]
  end

  def set_total_records_count_header
    response.headers["X-CM-Total-Records-Count"] = Record.count
  end
end
