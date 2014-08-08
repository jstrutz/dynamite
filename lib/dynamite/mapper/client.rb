require 'aws-sdk-core'

module Dynamite
  module Mapper
    module Client
      def client
        ::Aws::DynamoDB::Client.new(Dynamite.config)
      end
    end
  end
end
