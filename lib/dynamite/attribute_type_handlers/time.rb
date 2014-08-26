require_relative '../attribute_type_handler'

module Dynamite
  module AttributeTypeHandlers
    class Time < Dynamite::AttributeTypeHandler
      def self.handles_type?(type)
        handles_symbol?(type) || handles_class?(type)
      end

      def convert_to_dynamo_value(object_value)
        object_value.to_i.to_s
      end

      def convert_to_object_value(dynamo_value)
        ::Time.at(dynamo_value.to_i)
      end

    protected

      def self.handles_symbol?(type)
        [:time, :timestamp].include?(type)
      end

      def self.handles_class?(type)
        type.respond_to?(:ancestors) && type.ancestors.include?(::Time)
      end

      def dynamo_attribute_value_type_key
        :n
      end
    end
  end
end
