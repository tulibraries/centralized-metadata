require "rails_helper"
require "swagger_helper"

RSpec.describe "LocalVarLabels", type: :request do

  path "/records/{record_id}/local_var_labels" do
    get("show local variant label fields") do
      tags "local_var_labels"
      description "This web service retrieves the local variant label fields (cm_local_var_label) associated to a Centralized Metadata Repository record, formatted as a JSON array."
      parameter name: "record_id", in: :path, type: :string, description: "The id of the Centralized Metadata Repository record", required: true

      response(422, "unsuccessful") do
        let(:record_id) { "not-a-record" }  

        run_test!
      end

      response(200, "successful") do        

        before do
          make_local_var_labels_record(record_id, var_labels)
        end

        example "application/json", "no-var_labels", "[]"
        example "application/json", "a-var_label", [{id: 1, cm_local_var_label: "foo"}]
        example "application/json", "some-var_labels", [{id: 1, cm_local_var_label: "foo"}, {id: 2, cm_local_var_label: "bar"}]

        schema "$ref" => "#/components/schemas/LocalVarLabels"

        context "no local var_labels" do
          let (:record_id) { "no-local-var_labels-test" }
          let (:var_labels) { nil }

          run_test!  do | response|
            data = JSON.parse(response.body)
            expect(data).to eq([])
          end
        end

        context "a local var_label" do
          let (:record_id) { "a-local-var_label-test" }
          let (:var_labels) { ["foo"] }
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to eq([{"id" => 1, "cm_local_var_label" => "foo"}])
          end
        end

        context "some local var_labels" do
          let (:record_id) { "some-local-var_labels-test" }
          let (:var_labels) { ["foo", "bar"] }
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to eq([
              {"id" => 1, "cm_local_var_label" => "foo"},
              {"id" => 2, "cm_local_var_label" => "bar"},
            ])
          end
        end
      end
    end

    post("create local variant label fields") do
      tags "local_var_labels"
      consumes  "application/json"


      parameter name: "record_id", in: :path, type: :string, description: "The id of the Centralized Metadata Repository record", required: true
      parameter name: :local_var_label, in: :body, schema: { "$ref" => "#/components/schemas/LocalVarLabel" }, required: true

      request_body_example name: "default", value: { cm_local_var_label: "Hello World" }
      produces "application/json"

      description "The web service creates local variant label field(s) (cm_local_var_label) for a Centralized Metadata Repository record."

      response(422, "unsuccessful") do
        let(:record_id) { "not-a-record" }  
        let(:local_var_label) { { cm_local_var_label: "foo"} }

        run_test!
      end

      response(200, "successful") do        

        before do
          make_local_var_labels_record(record_id, var_labels)
        end

        example "application/json", "some-var_labels", [{id: 1, cm_local_var_label: "foo"}, {id: 2, cm_local_var_label: "bar"}]
        example "application/json", "a-var_label", [{id: 1, cm_local_var_label: "foo"}]

        schema "$ref" => "#/components/schemas/LocalVarLabels"

        context "Record has no previous var_labels" do
          let (:record_id) { "create-a-local-var_label" }
          let (:var_labels) { nil }
          let (:local_var_label) { { cm_local_var_label: "foo"} }

          run_test! do | response|

            data = JSON.parse(response.body)
            expect(data).to eq([{"id" => 1, "cm_local_var_label" => "foo"}])
          end
        end

        context "Record has a previous var_labels" do
          let (:record_id) { "create-a-local-var_label-2" }
          let (:var_labels) { ["bar"] }
          let (:local_var_label) { { cm_local_var_label: "foo"} }

          run_test! do | response|

            data = JSON.parse(response.body)
            expect(data).to eq([
              {"id" => 1, "cm_local_var_label" => "bar"},
              {"id" => 2, "cm_local_var_label" => "foo"},
            ])
          end
        end
      end
    end
  end

  path("/records/{record_id}/local_var_labels/{var_label_id}") do
    get("show local variant label field") do
      tags "local_var_labels"
      parameter name: "record_id", in: :path, type: :string, description: "The id of the Centralized Metadata Repository record", required: true
      parameter name: "var_label_id", in: :path, type: :string, description: "The id of the local variant label field", required: true
      produces "application/json"

      description "This web service retrieves the value of a local variant label field (cm_local_var_label) in a Centralized Metadata Repository record."
      response(422, "unsuccessful") do

        context "Record does not exist" do
          let(:var_label_id) { 1 }
          let(:record_id) { "not-a-record" }  
          let(:local_var_label) { { cm_local_var_label: "foo"} }

          run_test!
        end

        context "Record has no previous var_labels" do
          let (:var_label_id ) { 1 }
          let (:record_id) { "create-a-local-var_label" }
          let (:var_labels) { nil }
          let (:local_var_label) { { cm_local_var_label: "foo"} }

          run_test!
        end
      end

      response(200, "successful") do
        schema type: "string" 

        before do
          make_local_var_labels_record(record_id, var_labels)
        end

        context "Record has a var_label" do
          let (:record_id) { "create-a-local-var_label" }
          let (:var_labels) { ["foo"] }
          let (:var_label_id) { 1 }

          run_test! do | response|
            data = JSON.parse(response.body)
            expect(data).to eq("foo")
          end
        end
      end
    end

    put("update local variant label field") do
      tags "local_var_labels"
      consumes  "application/json"


      parameter name: "record_id", in: :path, type: :string, description: "The id of the Centralized Metadata Repository record", required: true
      parameter name: "var_label_id", in: :path, type: :string, description: "The id of the local variant label field", required: true

      parameter name: :local_var_label, in: :body, schema: { "$ref" => "#/components/schemas/LocalVarLabel" }, required: true

      produces "application/json"

      description "This web service updates the value of a local variant label field (cm_local_var_label) in a Centralized Metadata Repository record."

      response(422, "unsuccessful") do

        context "Record does not exist" do
          let(:var_label_id) { 1 }
          let(:record_id) { "not-a-record" }  
          let(:local_var_label) { { cm_local_var_label: "foo"} }

          run_test!
        end

        context "Record has no previous var_labels" do
          let (:var_label_id ) { 1 }
          let (:record_id) { "create-a-local-var_label" }
          let (:var_labels) { nil }
          let (:local_var_label) { { cm_local_var_label: "foo"} }

          run_test!
        end
      end

      response(200, "successful") do        

        before do
          make_local_var_labels_record(record_id, var_labels)
        end

        request_body_example name: "default", value: { cm_local_var_label: "Hello World" }

        schema "$ref" => "#/components/schemas/LocalVarLabel"


        context "Record has a previous var_labels" do
          let (:var_label_id) { 1 }
          let (:record_id) { "create-a-local-var_label-2" }
          let (:var_labels) { ["bar"] }
          let (:local_var_label) { { cm_local_var_label: "foo"} }

          run_test! do | response|

            data = JSON.parse(response.body)
            expect(data).to eq({"id" => 1, "cm_local_var_label" => "foo" })
          end
        end
      end
    end

    delete("delete local variant label field") do
      tags "local_var_labels"
      parameter name: "record_id", in: :path, type: :string, description: "The id of the Centralized Metadata Repository record", required: true
      parameter name: "var_label_id", in: :path, type: :string, description: "The id of the local variant label field", required: true
      produces "application/json"

      description "This web service deletes a local variant label field (cm_local_var_label) in a Centralized Metadata Repository record."

      response(422, "unsuccessful") do

        context "Record does not exist" do
          let(:var_label_id) { 1 }
          let(:record_id) { "not-a-record" }  
          let(:local_var_label) { { cm_local_var_label: "foo"} }

          run_test!
        end

        context "Record has no previous var_labels" do
          let (:var_label_id ) { 1 }
          let (:record_id) { "create-a-local-var_label" }
          let (:var_labels) { nil }
          let (:local_var_label) { { cm_local_var_label: "foo"} }

          run_test!
        end
      end

      response(200, "successful") do
        schema type: "string" 

        before do
          make_local_var_labels_record(record_id, var_labels)
        end

        context "Record has a var_label" do
          let (:record_id) { "create-a-local-var_label" }
          let (:var_labels) { ["foo"] }
          let (:var_label_id) { 1 }

          run_test! do | response|
            data = JSON.parse(response.body)
            expect(data).to eq("foo")

            record = Record.find_by(id: record_id)
            var_labels = record.local_metadatum.local_var_labels
            expect(var_labels).to eq([])
          end

        end

      end

    end
  end

  def make_local_var_labels_record(record_id, var_labels = [])
    record = Record.new(
      id: "#{record_id}",
      value: {
        "cm_id"=>["record_id"],
        "cm_pref_label"=>["Armstrong, Louis, 1901-1971. prf"],
        "cm_import_method"=>["MARC binary"],
        "cm_type"=>["personal name"],
        "cm_see_also"=>
      ["Biographical and program var_labels by Stanley Dance ([2] p. : 1 port.) in container; personnel and original issue and matrix no. on container.",
       "Louis Armstrong, trumpet and vocals, and his band."],
      })

    if ! var_labels.blank?
      metadatum = LocalMetadatum.create()

      var_labels.each do |n|
        var_label = LocalVarLabel.create(cm_local_var_label: n)
        metadatum.local_var_labels << var_label
      end
      record.local_metadatum = metadatum
    end

    record.save!
  end
end

