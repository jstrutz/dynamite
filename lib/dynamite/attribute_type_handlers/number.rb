require_relative '../attribute_type_handler'

module Dynamite
  module AttributeTypeHandlers
    class Number < Dynamite::AttributeTypeHandler
      def self.handles_type?(type)
        handles_symbol?(type) || handles_class?(type)
      end

    protected

      def self.handles_symbol?(type)
        [:int, :num, :integer, :number, :numeric].include?(type)
      end

      def self.handles_class?(type)
        type.respond_to?(:ancestors) && type.ancestors.include?(::Numeric)
      end

      def convert_to_object_value(dynamo_value); dynamo_value.to_i; end
      def convert_to_dynamo_value(object_value); object_value.to_s; end

      def dynamo_attribute_value_type_key
        :n
      end
    end
  end
end
