module Dynamite
  class AttributeTypeHandler
    class InvalidTypeError < StandardError; end
    class << self
      def handlers
        Thread.current[:attribute_type_handlers] || []
      end

      def handles_type?(type)
        false
      end

      def for(type_def)
        handlers.find {|handler| handler.handles_type?(type_def) }
      end

      def inherited(subclass)
        Thread.current[:attribute_type_handlers] ||= []
        Thread.current[:attribute_type_handlers] << subclass
      end
    end

    def initialize(attr)
      @attr = attr
    end


    def dynamo_attribute(mapped_obj)
      dynamo_attribute_from_value @attr.object_reader.call(mapped_obj)
    end

    def set_object_attribute!(mapped_obj, dynamo_data)
      # puts "setting attribubte for #{@attr.name.to_s} from #{dynamo_data.inspect}"
      obj_val = object_value_from_dynamo_data(dynamo_data)
      @attr.object_writer.call(
        mapped_obj,
        convert_to_object_value(obj_val)
      ) if obj_val
    end

    # A full attribute hash, used by the SDK for writing.
    # This is in an annoyingly different format than that which is returned
    # by the SDK when getting an item.
    def dynamo_attribute_from_value(attr_val)
      # { dynamo_attribute_key => { dynamo_attribute_value_type_key => convert_to_dynamo_value(attr_val) }} unless attr_val.nil?
      { dynamo_attribute_key => convert_to_dynamo_value(attr_val)} unless attr_val.nil?
    end

    def dynamo_attribute_list_comparison_from_value(operator, attr_vals)
      # { dynamo_attribute_key => { dynamo_attribute_value_type_key => convert_to_dynamo_value(attr_val) }} unless attr_val.nil?
      { dynamo_attribute_key => {
        attribute_value_list: attr_vals.map {|attr_val| convert_to_dynamo_value(attr_val) unless attr_val.nil? }.compact,
        comparison_operator: operator.to_s }}
    end


    # DynamoDB's Ruby uses lowercase symbols (:n, :s, :b ...) for attribute
    # values, but uses uppercase strings as keys for attribute definitions.
    # Override this in the AttributeTypeHandler subclass for types which cannot
    # be keys, in which case this should return nil.
    def dynamo_attribute_definition_type
      dynamo_attribute_value_type_key.to_s.upcase
    end

  protected
    # Override this to produce a value suitable for storing in dynamo.  This
    # is the place to do type conversions.
    def convert_to_dynamo_value(object_value); object_value; end

    # Override this to convert a value out of dynamo back into something
    # suitable for your application, such as deserializing, parsing, etc.
    def convert_to_object_value(dynamo_value); dynamo_value; end

    # Gets data out of the attribute value hash returned from the dynamo sdk
    def object_value_from_dynamo_data(dynamo_record)
      dynamo_record[dynamo_attribute_key]
    end

    # The string for the name of the field in dynamo
    def dynamo_attribute_key
      @attr.dynamo_name
    end
  end
end
