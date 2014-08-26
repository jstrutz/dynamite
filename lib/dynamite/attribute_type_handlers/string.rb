require_relative '../attribute_type_handler'

module Dynamite
  module AttributeTypeHandlers
    class String < Dynamite::AttributeTypeHandler
      def self.handles_type?(type)
        [:string, :uuid, ::String].include?(type)
      end

    protected
      def dynamo_attribute_value_type_key
        :s
      end
    end
  end
end
