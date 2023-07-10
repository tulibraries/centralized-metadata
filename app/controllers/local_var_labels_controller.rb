class LocalVarLabelsController < ApplicationController
  rescue_from Exception do |exception|
    render json: exception, status: :unprocessable_entity
  end

  def index
    record = Record.find(params[:record_id])
    local_var_labels = record.local_metadatum&.local_var_labels || []
    render json: local_var_labels
  end

  def show
    record = Record.find(params[:record_id])
    metadatum = get_metadatum(record)
    var_label = metadatum.local_var_labels.find_by(id: params[:var_label_id])
    render json: var_label.cm_local_var_label.to_json
  end

  def create
    record = Record.find(params[:record_id])
    metadatum = get_metadatum(record)

    var_label = LocalVarLabel.new(cm_local_var_label: params[:cm_local_var_label])

    metadatum.local_var_labels << var_label
    record.local_metadatum = metadatum
    record.save!

    render json: metadatum.local_var_labels
  end


  def update
    record = Record.find(params[:record_id])
    metadatum = get_metadatum(record)

    var_label = metadatum.local_var_labels.find_by(id: params[:var_label_id])
    var_label.cm_local_var_label = params[:cm_local_var_label]
    var_label.save!

    render json: var_label
  end

  def destroy
    record = Record.find(params[:record_id])
    metadatum = get_metadatum(record)
    var_label = metadatum.local_var_labels.find_by(id: params[:var_label_id])
    var_label.destroy!

    render json: var_label.cm_local_var_label.to_json
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
