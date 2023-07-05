# frozen_string_literal: true

require 'rails_helper'
require 'centralized_metadata'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Centralized Metadata Records',
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

        components: {
          schemas: {
            LocalNote: {
              type: "object",
              required: ["cm_local_note"],
              properties:  { id: { type: "integer"}, cm_local_note: { type: "string"} },
            },
            LocalNotes: {
              type: "array",
              items: { "$ref" => "#/components/schemas/LocalNote" },
            },
            LocalVariant: {
              type: "object",
              required: ["cm_local_var_label"],
              properties:  { id: { type: "integer"}, cm_local_var_label: { type: "string"} },
            },
            LocalVariants: {
              type: "array",
              items: { "$ref" => "#/components/schemas/LocalVariant" }
            },
            Record: {
              type: "object",
              required: %w(cm_id),
              properties: CentralizedMetadata::Indexer.fields.reduce({}) { |acc, f|
                acc.merge("#{f}": {
                  type: "array",
                  items: { type: "string" },
                })
              }
            },
            Records: {
              type: "array",
              items: { "$ref" => "#/components/schemas/Record" }
            },
          }
        }
    }

  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end
