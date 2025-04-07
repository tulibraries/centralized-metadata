require "centralized_metadata"

class MarcFileController < ApplicationController

  include TotalRecordsCountHeader
  include RecordsProcessedCountHeader

  rescue_from Exception do |exception|
    unless performed?
      render json: exception, status: :unprocessable_entity
    end
  end

  def delete
    ids = get_ids(params)
    @records = Record.where(id: ids)
    @records_count = @records
    records_to_render = @records.to_a
    @records.destroy_all
    response.headers["X-CM-Records-Processed-Count"] = @records_count.count
    response.headers["X-CM-Total-Records-Count"] = Record.count

    render json: records_to_render
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
