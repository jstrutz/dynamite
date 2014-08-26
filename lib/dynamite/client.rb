require 'aws-sdk-core'

module Dynamite
  module Client
    def client
      ::Aws::DynamoDB::Client.new(Dynamite.dynamo_client_config)
    end
  end
end
