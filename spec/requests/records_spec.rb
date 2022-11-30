require 'swagger_helper'

RSpec.describe 'records', type: :request do

  path '/records' do
    get('list records') do
      description "This web service returns records in a JSON format. 
      The pagination default is set to return 25 records at a time. If you would like to change this,
      add the parameter per_page=number_desired to the query parameters."
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    post('create record') do
      description "This web service creates a new record. There are two methods for adding records.\n
      Using a curl statement: curl -F 'marc_file=@spec/fixtures/marc/louis_armstrong.mrc' https://centralized-metadata-qa.k8s.temple.edu \n
      Ingest with a rake task: rake db:ingest[spec/fixtures/marc]."
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/records/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show record') do
      description "This web service returns an indivudual record in JSON format."
      response(200, 'successful') do
        let(:id) { '123' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    patch('update record') do
      description "This web serive updates a record."
      response(200, 'successful') do
        let(:id) { '123' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    put('update record') do
      description "This web serive updates a record."
      response(200, 'successful') do
        let(:id) { '123' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    delete('delete record') do
      description "This web serive deletes a record."
      response(200, 'successful') do
        let(:id) { '123' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end
end
