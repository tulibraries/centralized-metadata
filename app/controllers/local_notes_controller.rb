class LocalNotesController < ApplicationController
  rescue_from Exception do |exception|
    render json: exception, status: :unprocessable_entity
  end

  def index
    record = Record.find(params[:record_id])
    local_notes = record.local_metadatum&.local_notes || []
    render json: local_notes
  end

  def show
    record = Record.find(params[:record_id])
    metadatum = get_metadatum(record)
    note = metadatum.local_notes.find_by(id: params[:note_id])
    render json: note.cm_local_note.to_json
  end

  def create
    record = Record.find(params[:record_id])
    metadatum = get_metadatum(record)

    note = LocalNote.new(cm_local_note: params[:cm_local_note])

    metadatum.local_notes << note
    record.local_metadatum = metadatum
    record.save!

    render json: metadatum.local_notes
  end


  def update
    record = Record.find(params[:record_id])
    metadatum = get_metadatum(record)

    note = metadatum.local_notes.find_by(id: params[:note_id])
    note.cm_local_note = params[:cm_local_note]
    note.save!

    render json: note
  end

  def destroy
    record = Record.find(params[:record_id])
    metadatum = get_metadatum(record)
    note = metadatum.local_notes.find_by(id: params[:note_id])
    note.destroy!

    render json: note.cm_local_note.to_json
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
