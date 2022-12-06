Rswag::Api.configure do |c|

  # Specify a root folder where Swagger JSON files are located
  # This is used by the Swagger middleware to serve requests for API descriptions
  # NOTE: If you're using rswag-specs to generate Swagger, you'll need to ensure
  # that it's configured to generate files in the same folder
  c.swagger_root = Rails.root.to_s + '/swagger'

  # Inject a lambda function to alter the returned Swagger prior to serialization
  # The function will have access to the rack env for the current request
  # For example, you could leverage this to dynamically assign the "host" property
  #
  c.swagger_filter = lambda do |swagger, env|

    swagger['host'] = env['HTTP_HOST']
    http = swagger['host'].match(/localhost/) ? 'http' : 'https'


    # Use variables to iterate and replace with values in the swagger file template.
    variables = {
      '$http' => http,
      '$host' => swagger['host']
    }

    transform_values!(swagger, variables)
  end

  private

  # This is a deep value replacement for a hash object.
  def self.transform_values!(value, variables={})
    if value.is_a? String
      variables.each do |k, v|
        value.sub!(k, v)
      end
      value
    elsif value.is_a? Hash
      value.transform_values! { |v| transform_values!(v, variables) }
    elsif value.is_a? Array
      value.map { |v| transform_values!(v, variables) }
    else
      value
    end
  end
end
