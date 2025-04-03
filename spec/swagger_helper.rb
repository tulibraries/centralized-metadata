# frozen_string_literal: true

require 'rails_helper'
require 'centralized_metadata'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s
  config.openapi_strict_schema_validation = false
  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Centralized Metadata Repository',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'https://centralized-metadata-qa.k8s.temple.edu',
        },
        {
          url: 'http://localhost:3000',
        },
        {
          url: 'http://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'localhost:3000'
            }
          }
        },
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'centralized-metadata-qa.k8s.temple.edu'
            }
          }
        }],

                #The property '#/0' contained undefined properties: 'cm_created_at, cm_updated_at, local_metadatum'
        components: {
          schemas: {
            Record: {
              type: "object",
              properties: CentralizedMetadata::Indexer.fields.reduce({}) { |acc, f|
                acc.merge("#{f}": {
                  type: "array",
                  items: { type: "string" },
                })
              }.merge({
                "cm_created_at": { type: "string", format: "date" },
                "cm_updated_at": { type: "string", format: "date" },
                "local_metadatum": { "$ref" => "#/components/schemas/LocalMetadatum", "x-nullable": true }

              }),
              required: [ "cm_id" ],
            },
            Records: {
              type: "array",
              items: { "$ref" => "#/components/schemas/Record" }
            },
            LocalNote: {
              type: "object",
              required: ["cm_local_note"],
              properties:  { id: { type: "integer"}, cm_local_note: { type: "string"} },
            },
            LocalNotes: {
              type: "array",
              items: { "$ref" => "#/components/schemas/LocalNote" },
            },
            LocalVarLabel: {
              type: "object",
              required: ["cm_local_var_label"],
              properties:  { id: { type: "integer"}, cm_local_var_label: { type: "string"} },
            },
            LocalVarLabels: {
              type: "array",
              items: { "$ref" => "#/components/schemas/LocalVarLabel" }
            },
            LocalMetadatum: {
              type: "object",
              properties: {
                local_notes: { type: :array, "$ref" => "#/components/schemas/LocalNotes" },
                local_var_labels: { type: :array, "$ref" => "#/components/schemas/LocalVarLabels" },
              }
            },
          }
        }
    }

  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
