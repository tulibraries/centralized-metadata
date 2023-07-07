require "rails_helper"
require "swagger_helper"

RSpec.describe "LocalVariants", type: :request do

  path "/records/{record_id}/local_variants" do
    get("local_variants of a record") do
      tags "local_variants"
      description "Returns a JSON array of local variants associated to a specific record."
      parameter name: "record_id", in: :path, type: :string, description: "The id of the centralized metadata record", required: true

      response(422, "unsuccessful") do
        let(:record_id) { "not-a-record" }  

        run_test!
      end

      response(200, "successful") do        

        before do
          make_local_variants_record(record_id, variants)
        end

        example "application/json", "no-variants", "[]"
        example "application/json", "a-variant", [{id: 1, cm_local_var_label: "foo"}]
        example "application/json", "some-variants", [{id: 1, cm_local_var_label: "foo"}, {id: 2, cm_local_var_label: "bar"}]

        schema "$ref" => "#/components/schemas/LocalVariants"

        context "no local variants" do
          let (:record_id) { "no-local-variants-test" }
          let (:variants) { nil }

          run_test!  do | response|
            data = JSON.parse(response.body)
            expect(data).to eq([])
          end
        end

        context "a local variant" do
          let (:record_id) { "a-local-variant-test" }
          let (:variants) { ["foo"] }
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to eq([{"id" => 1, "cm_local_var_label" => "foo"}])
          end
        end

        context "some local variants" do
          let (:record_id) { "some-local-variants-test" }
          let (:variants) { ["foo", "bar"] }
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

    post("create a new variant") do
      tags "local_variants"
      consumes  "application/json"


      parameter name: "record_id", in: :path, type: :string, description: "The id of the centralized metadata record", required: true
      parameter name: :local_variant, in: :body, schema: { "$ref" => "#/components/schemas/LocalVariant" }, required: true

      request_body_example name: "default", value: { cm_local_var_label: "Hello World" }
      produces "application/json"

      description "This endpoint creates a new local variant for specified record"

      response(422, "unsuccessful") do
        let(:record_id) { "not-a-record" }  
        let(:local_variant) { { cm_local_var_label: "foo"} }

        run_test!
      end

      response(200, "successful") do        

        before do
          make_local_variants_record(record_id, variants)
        end

        example "application/json", "some-variants", [{id: 1, cm_local_var_label: "foo"}, {id: 2, cm_local_var_label: "bar"}]
        example "application/json", "a-variant", [{id: 1, cm_local_var_label: "foo"}]

        schema "$ref" => "#/components/schemas/LocalVariants"

        context "Record has no previous variants" do
          let (:record_id) { "create-a-local-variant" }
          let (:variants) { nil }
          let (:local_variant) { { cm_local_var_label: "foo"} }

          run_test! do | response|

            data = JSON.parse(response.body)
            expect(data).to eq([{"id" => 1, "cm_local_var_label" => "foo"}])
          end
        end

        context "Record has a previous variants" do
          let (:record_id) { "create-a-local-variant-2" }
          let (:variants) { ["bar"] }
          let (:local_variant) { { cm_local_var_label: "foo"} }

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

  path("/records/{record_id}/local_variants/{variant_id}") do
    get("show a local variant") do
      tags "local_variants"
      parameter name: "record_id", in: :path, type: :string, description: "The id of the centralized metadata record", required: true
      parameter name: "variant_id", in: :path, type: :string, description: "The id of the centralized metadata local variant", required: true
      produces "application/json"

      description "This endpoint returns value o a specific local variant."
      response(422, "unsuccessful") do

        context "Record does not exist" do
          let(:variant_id) { 1 }
          let(:record_id) { "not-a-record" }  
          let(:local_variant) { { cm_local_var_label: "foo"} }

          run_test!
        end

        context "Record has no previous variants" do
          let (:variant_id ) { 1 }
          let (:record_id) { "create-a-local-variant" }
          let (:variants) { nil }
          let (:local_variant) { { cm_local_var_label: "foo"} }

          run_test!
        end
      end

      response(200, "successful") do
        schema type: "string" 

        before do
          make_local_variants_record(record_id, variants)
        end

        context "Record has a variant" do
          let (:record_id) { "create-a-local-variant" }
          let (:variants) { ["foo"] }
          let (:variant_id) { 1 }

          run_test! do | response|
            data = JSON.parse(response.body)
            expect(data).to eq("foo")
          end
        end
      end
    end

    delete("delete a local variant") do
      tags "local_variants"
      parameter name: "record_id", in: :path, type: :string, description: "The id of the centralized metadata record", required: true
      parameter name: "variant_id", in: :path, type: :string, description: "The id of the centralized metadata local variant", required: true
      produces "application/json"

      description "This endpoint deletes a specific local variant."

      response(422, "unsuccessful") do

        context "Record does not exist" do
          let(:variant_id) { 1 }
          let(:record_id) { "not-a-record" }  
          let(:local_variant) { { cm_local_var_label: "foo"} }

          run_test!
        end

        context "Record has no previous variants" do
          let (:variant_id ) { 1 }
          let (:record_id) { "create-a-local-variant" }
          let (:variants) { nil }
          let (:local_variant) { { cm_local_var_label: "foo"} }

          run_test!
        end
      end

      response(200, "successful") do
        schema type: "string" 

        before do
          make_local_variants_record(record_id, variants)
        end

        context "Record has a variant" do
          let (:record_id) { "create-a-local-variant" }
          let (:variants) { ["foo"] }
          let (:variant_id) { 1 }

          run_test! do | response|
            data = JSON.parse(response.body)
            expect(data).to eq("foo")

            record = Record.find_by(id: record_id)
            variants = record.local_metadatum.local_variants
            expect(variants).to eq([])
          end

        end

      end

    end

    put("update a  variant") do
      tags "local_variants"
      consumes  "application/json"


      parameter name: "record_id", in: :path, type: :string, description: "The id of the centralized metadata record", required: true
      parameter name: "variant_id", in: :path, type: :string, description: "The id of the centralized metadata local variant", required: true

      parameter name: :local_variant, in: :body, schema: { "$ref" => "#/components/schemas/LocalVariant" }, required: true

      produces "application/json"

      description "This endpoint updates a local variant for specified record"

      response(422, "unsuccessful") do

        context "Record does not exist" do
          let(:variant_id) { 1 }
          let(:record_id) { "not-a-record" }  
          let(:local_variant) { { cm_local_var_label: "foo"} }

          run_test!
        end

        context "Record has no previous variants" do
          let (:variant_id ) { 1 }
          let (:record_id) { "create-a-local-variant" }
          let (:variants) { nil }
          let (:local_variant) { { cm_local_var_label: "foo"} }

          run_test!
        end
      end

      response(200, "successful") do        

        before do
          make_local_variants_record(record_id, variants)
        end

        request_body_example name: "default", value: { cm_local_var_label: "Hello World" }

        schema "$ref" => "#/components/schemas/LocalVariant"


        context "Record has a previous variants" do
          let (:variant_id) { 1 }
          let (:record_id) { "create-a-local-variant-2" }
          let (:variants) { ["bar"] }
          let (:local_variant) { { cm_local_var_label: "foo"} }

          run_test! do | response|

            data = JSON.parse(response.body)
            expect(data).to eq({"id" => 1, "cm_local_var_label" => "foo" })
          end
        end
      end
    end
  end

  def make_local_variants_record(record_id, variants = [])
    record = Record.new(
      id: "#{record_id}",
      value: {
        "cm_id"=>["record_id"],
        "cm_pref_label"=>["Armstrong, Louis, 1901-1971. prf"],
        "cm_import_method"=>["MARC binary"],
        "cm_type"=>["personal name"],
        "cm_see_also"=>
      ["Biographical and program variants by Stanley Dance ([2] p. : 1 port.) in container; personnel and original issue and matrix no. on container.",
       "Louis Armstrong, trumpet and vocals, and his band."],
      })

    if ! variants.blank?
      metadatum = LocalMetadatum.create()

      variants.each do |n|
        variant = LocalVariant.create(cm_local_var_label: n)
        metadatum.local_variants << variant
      end
      record.local_metadatum = metadatum
    end

    record.save!
  end
end

