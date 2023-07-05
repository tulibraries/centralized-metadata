class LocalVariantsController < ApplicationController
  rescue_from Exception do |exception|
    render json: exception, status: :unprocessable_entity
  end

  def index
    record = Record.find(params[:record_id])
    local_variants = record.local_metadatum&.local_variants || []
    render json: local_variants
  end

  def show
    record = Record.find(params[:record_id])
    metadatum = get_metadatum(record)
    variant = metadatum.local_variants.find_by(id: params[:variant_id])
    render json: variant.cm_local_var_label.to_json
  end

  def create
    record = Record.find(params[:record_id])
    metadatum = get_metadatum(record)

    variant = LocalVariant.new(cm_local_var_label: params[:cm_local_var_label])

    metadatum.local_variants << variant
    record.local_metadatum = metadatum
    record.save!

    render json: metadatum.local_variants
  end


  def update
    record = Record.find(params[:record_id])
    metadatum = get_metadatum(record)

    variant = metadatum.local_variants.find_by(id: params[:variant_id])
    variant.cm_local_var_label = params[:cm_local_var_label]
    variant.save!

    render json: variant
  end

  def destroy
    record = Record.find(params[:record_id])
    metadatum = get_metadatum(record)
    variant = metadatum.local_variants.find_by(id: params[:variant_id])
    variant.destroy!

    render json: variant.cm_local_var_label.to_json
  end

  private

  def get_metadatum(record)
    if record.local_metadatum.nil?
      LocalMetadatum.new
    else
      record.local_metadatum
    end
  end
end
