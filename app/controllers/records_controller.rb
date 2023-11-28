# frozen_string_literal: true
require "centralized_metadata"

class RecordsController < ApplicationController
  include TotalRecordsCountHeader
  include RecordsProcessedCountHeader

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
    options = { original_filename: params[:marc_file].original_filename }
    @records = CentralizedMetadata::Indexer.ingest(marc_file, options)
    render json: @records
  end

  # PATCH/PUT /records/1
  def update
    begin
      id = params.require(:id)
      cm_id = params.require(:cm_id)&.first
    rescue => e
      @record.errors.add(:params, "#{e.message}")
    end

    if id != cm_id
      @record.errors.add(:cm_id, "The :cm_id and :id values must match.")
    end

    if @record.errors.blank?
      if request.put?
        @record.value = value_params
      elsif request.patch?
        @record.value.merge!(value_params)
      end
      @record.save!
    end

    if  @record.errors.blank?
      render json: @record
    else
      render json: @record.errors, status: :unprocessable_entity
    end
  end

  # DELETE /records/1
  def destroy
   render json: @record.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_record
      @record = Record.find(params[:id])

      # Somtimes the JSON string is not evaluated.
      # Maybe just in the test environment?
      if @record.value.is_a? String
        @record.value = JSON.parse(@record.value)
      end
    end

    # Only allow a list of trusted parameters through.
    def value_params
      params.slice(*CentralizedMetadata::Indexer.fields).permit!.to_hash
    end
end
