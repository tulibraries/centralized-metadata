require "centralized_metadata"

class RecordsController < ApplicationController
  before_action :set_record, only: %i[ show update destroy ]

  # GET /records
  def index
    paginate json: Record.all
  end

  # GET /records/1
  def show
    render json: @record
  end

  # POST /records
  def create
    params.permit(:marc_file)

    marc_file = params[:marc_file].tempfile
    CentralizedMetadata::Indexer.ingest(marc_file, { original_filename: params[:marc_file].original_filename })
  end

  # PATCH/PUT /records/1
  def update
    if @record.update(record_params)
      render json: @record
    else
      render json: @record.errors, status: :unprocessable_entity
    end
  end

  # DELETE /records/1
  def destroy
    @record.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_record
      @record = Record.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def record_params
      params.require(:record).permit(:id, :value,
       local_metadatum_attributes: [:cm_local_pref_label, :cm_local_var_label, :cm_local_note]
      )
    end
end
