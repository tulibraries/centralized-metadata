require "centralized_metadata"

class MarcFileController < ApplicationController

  include TotalRecordsCountHeader
  include RecordsProcessedCountHeader

  rescue_from Exception do |exception|
    render json: exception, status: :unprocessable_entity
  end

  def delete
    ids = get_ids(params)
    @records = Record.where(id: ids).destroy_all
    render json: @records
  end

  def ids
    render json: get_ids(params)
  end

  private

  def get_ids(params)
    get_records(params)
      .map { |f| f["cm_id"] }
      .flatten
  end

  def get_records(params)
    file =  params.permit(:marc_file)[:marc_file]
    CentralizedMetadata::Indexer.get_records(file.tempfile)
  end
end
