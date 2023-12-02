require "rails_helper"
require "swagger_helper"

RSpec.describe "LocalNotes", type: :request do

  path "/records/{record_id}/local_notes" do
    get("show local note fields") do
      tags "local_notes"
      description "Retrieves local note field(s) (cm_local_note) associated with a Centralized Metadata Repository record, as a JSON array."
      parameter name: "record_id", in: :path, type: :string, description: "The id of the Centralized Metadata Repository record", required: true

      response(422, "unsuccessful") do
        let(:record_id) { "not-a-record" }

        run_test!
      end

      response(200, "successful") do

        before do
          make_local_notes_record(record_id, notes)
        end

        example "application/json", "no-notes", "[]"
        example "application/json", "a-note", [{id: 1, cm_local_note: "foo"}]
        example "application/json", "some-notes", [{id: 1, cm_local_note: "foo"}, {id: 2, cm_local_note: "bar"}]

        schema "$ref" => "#/components/schemas/LocalNotes"

        context "no local notes" do
          let (:record_id) { "no-local-notes-test" }
          let (:notes) { nil }

          run_test!  do | response|
            data = JSON.parse(response.body)
            expect(data).to eq([])
          end
        end

        context "a local note" do
          let (:record_id) { "a-local-note-test" }
          let (:notes) { ["foo"] }
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to eq([{"id" => 1, "cm_local_note" => "foo"}])
          end
        end

        context "some local notes" do
          let (:record_id) { "some-local-notes-test" }
          let (:notes) { ["foo", "bar"] }
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to eq([
              {"id" => 1, "cm_local_note" => "foo"},
              {"id" => 2, "cm_local_note" => "bar"},
            ])
          end
        end
      end
    end

    post("create local note fields") do
      tags "local_notes"
      consumes  "application/json"


      parameter name: "record_id", in: :path, type: :string, description: "The id of the Centralized Metadata Repository record", required: true
      parameter name: :local_note, in: :body, schema: { "$ref" => "#/components/schemas/LocalNote" }, required: true

      request_body_example name: "default", value: { cm_local_note: "Hello World" }
      produces "application/json"

      description "Creates local note field(s) (cm_local_note) for a Centralized Metadata Repository record."

      response(422, "unsuccessful") do
        let(:record_id) { "not-a-record" }
        let(:local_note) { { cm_local_note: "foo"} }

        run_test!
      end

      response(200, "successful") do

        before do
          make_local_notes_record(record_id, notes)
        end

        example "application/json", "some-notes", [{id: 1, cm_local_note: "foo"}, {id: 2, cm_local_note: "bar"}]
        example "application/json", "a-note", [{id: 1, cm_local_note: "foo"}]

        schema "$ref" => "#/components/schemas/LocalNotes"

        context "Record has no previous notes" do
          let (:record_id) { "create-a-local-note" }
          let (:notes) { nil }
          let (:local_note) { { cm_local_note: "foo"} }

          run_test! do | response|

            data = JSON.parse(response.body)
            expect(data).to eq([{"id" => 1, "cm_local_note" => "foo"}])
          end
        end

        context "Record has a previous notes" do
          let (:record_id) { "create-a-local-note-2" }
          let (:notes) { ["bar"] }
          let (:local_note) { { cm_local_note: "foo"} }

          run_test! do | response|

            data = JSON.parse(response.body)
            expect(data).to eq([
              {"id" => 1, "cm_local_note" => "bar"},
              {"id" => 2, "cm_local_note" => "foo"},
            ])
          end
        end
      end
    end
  end

  path("/records/{record_id}/local_notes/{note_id}") do
    get("show local note field") do
      tags "local_notes"
      parameter name: "record_id", in: :path, type: :string, description: "The id of the Centralized Metadata Repository record", required: true
      parameter name: "note_id", in: :path, type: :string, description: "The id of the local note field", required: true
      produces "application/json"

      description "Retrieves the value of a local note field (cm_local_note) from a Centralized Metadata Repository record."
      response(422, "unsuccessful") do

        context "Record does not exist" do
          let(:note_id) { 1 }
          let(:record_id) { "not-a-record" }
          let(:local_note) { { cm_local_note: "foo"} }

          run_test!
        end

        context "Record has no previous notes" do
          let (:note_id ) { 1 }
          let (:record_id) { "create-a-local-note" }
          let (:notes) { nil }
          let (:local_note) { { cm_local_note: "foo"} }

          run_test!
        end
      end

      response(200, "successful") do
        schema type: "string"

        before do
          make_local_notes_record(record_id, notes)
        end

        context "Record has a note" do
          let (:record_id) { "create-a-local-note" }
          let (:notes) { ["foo"] }
          let (:note_id) { 1 }

          run_test! do | response|
            data = JSON.parse(response.body)
            expect(data).to eq("foo")
          end
        end
      end
    end

    put("update local note field") do
      tags "local_notes"
      consumes  "application/json"


      parameter name: "record_id", in: :path, type: :string, description: "The id of the Centralized Metadata Repository record", required: true
      parameter name: "note_id", in: :path, type: :string, description: "The id of the local note field", required: true

      parameter name: :local_note, in: :body, schema: { "$ref" => "#/components/schemas/LocalNote" }, required: true

      produces "application/json"

      description "Updates a local note field (cm_local_note) in a Centralized Metadata Repository record."

      response(422, "unsuccessful") do

        context "Record does not exist" do
          let(:note_id) { 1 }
          let(:record_id) { "not-a-record" }
          let(:local_note) { { cm_local_note: "foo"} }

          run_test!
        end

        context "Record has no previous notes" do
          let (:note_id ) { 1 }
          let (:record_id) { "create-a-local-note" }
          let (:notes) { nil }
          let (:local_note) { { cm_local_note: "foo"} }

          run_test!
        end
      end

      response(200, "successful") do

        before do
          make_local_notes_record(record_id, notes)
        end

        request_body_example name: "default", value: { cm_local_note: "Hello World" }

        schema "$ref" => "#/components/schemas/LocalNote"


        context "Record has a previous notes" do
          let (:note_id) { 1 }
          let (:record_id) { "create-a-local-note-2" }
          let (:notes) { ["bar"] }
          let (:local_note) { { cm_local_note: "foo"} }

          run_test! do | response|

            data = JSON.parse(response.body)
            expect(data).to eq({"id" => 1, "cm_local_note" => "foo" })
          end
        end
      end
    end

    delete("delete local note field") do
      tags "local_notes"
      parameter name: "record_id", in: :path, type: :string, description: "The id of the Centralized Metadata Repository record", required: true
      parameter name: "note_id", in: :path, type: :string, description: "The id of the local note field", required: true
      produces "application/json"

      description "Deletes a local note field (cm_local_note) from a Centralized Metadata Repository record."

      response(422, "unsuccessful") do

        context "Record does not exist" do
          let(:note_id) { 1 }
          let(:record_id) { "not-a-record" }
          let(:local_note) { { cm_local_note: "foo"} }

          run_test!
        end

        context "Record has no previous notes" do
          let (:note_id ) { 1 }
          let (:record_id) { "create-a-local-note" }
          let (:notes) { nil }
          let (:local_note) { { cm_local_note: "foo"} }

          run_test!
        end
      end

      response(200, "successful") do
        schema type: "string"

        before do
          make_local_notes_record(record_id, notes)
        end

        context "Record has a note" do
          let (:record_id) { "create-a-local-note" }
          let (:notes) { ["foo"] }
          let (:note_id) { 1 }

          run_test! do | response|
            data = JSON.parse(response.body)
            expect(data).to eq("foo")

            record = Record.find_by(id: record_id)
            notes = record.local_metadatum.local_notes
            expect(notes).to eq([])
          end

        end

      end

    end

  end

  def make_local_notes_record(record_id, notes = [])
    record = Record.new(
      id: "#{record_id}",
      value: {
        "cm_id"=>["record_id"],
        "cm_pref_label"=>["Armstrong, Louis, 1901-1971. prf"],
        "cm_import_method"=>["MARC binary"],
        "cm_type"=>["personal name"],
        "cm_see_also"=>
      ["Biographical and program notes by Stanley Dance ([2] p. : 1 port.) in container; personnel and original issue and matrix no. on container.",
       "Louis Armstrong, trumpet and vocals, and his band."],
      })

    if ! notes.blank?
      metadatum = LocalMetadatum.create()

      notes.each do |n|
        note = LocalNote.create(cm_local_note: n)
        metadatum.local_notes << note
      end
      record.local_metadatum = metadatum
    end

    record.save!
  end
end

