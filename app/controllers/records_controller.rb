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
      params.require(:record).permit(:id, :cm_id, :cm_pref_label, :cm_var_label, :cm_source_vocab, 
        :cm_import_method, :cm_type, :cm_see_also, :cm_filename, :cm_skos_exact_match, 
        :cm_skos_close_match, :cm_lc_class, :cm_created_at, :cm_updated_at, :cm_narrower_term,
        :cm_broader_term, :cm_use_subject, :cm_undiff_name, :cm_birth_date, :cm_death_date,
        :cm_establishment_date, :cm_termination_date, :cm_start_period, :cm_end_period, :cm_place_of_birth,
        :cm_place_of_death, :cm_associated_country, :cm_residencehq, :cm_other_associated_place,
        :cm_field_activity, :cm_associated_group, :cm_occupation, :cm_gender, :cm_type_family,
        :cm_prom_member, :cm_heredity_title, :cm_associated_language, :cm_fuller_name, :cm_type_corporate_body,
        :cm_type_jurisdiction, :cm_other_designation, :cm_title_person, :cm_content_type,
        :cm_form_work, :cm_medium_performance, :cm_solist, :cm_doubling_instrument, :cm_alternative_medium_performance,
        :cm_original_key, :cm_transposed_key, :cm_music_num_designation, :cm_audience_characteristics,
        :cm_characteristics, :cm_work_time_creation, :cm_aggwork_time_creation, :cm_work_language,
        :cm_notmusic_format, :cm_beginning_date_created, :cm_ending_date_created, :cm_place_of_birth,
        :cm_place_origin_work, :cm_series_pubdates, :cm_series_num_peculiar, :cm_series_num_ex,
        :cm_series_placepub, :cm_series_analysis, :cm_series_tracing_practice, :cm_series_classificaton_practice,
        local_metadatum_attributes: [:cm_local_pref_label, :cm_local_var_label, :cm_local_note])
    end

end
