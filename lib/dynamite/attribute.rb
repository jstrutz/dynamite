module Dynamite
  class Attribute
    class InvalidTypeError < StandardError; end

    SYMBOL_TYPES = {
      numeric: :n,
      integer: :n,
      number:  :n,
      string:  :s,
      binary:  :b
    }.freeze
    ARRAY_SYMBOL_TYPES = {
      numbers:  :ns,
      ints:     :ns,
      numerics: :ns,
      strings:  :ss,
      binaries: :bs,
      array_of_nums: :ns,
      array_of_numbers: :ns,
      array_of_strings: :ss,
      array_of_binaries: :bs
    }.freeze
    CLASS_TYPES = {
      Numeric => :n,
      String  => :s,
    }.freeze


    attr_reader :name

    def initialize(name, klass_or_sym, opts = {})
      @name = name.to_sym
      @klass_or_sym = klass_or_sym
    end

    def dynamo_attribute_definition_type
      @dynamo_attribute_definition_type ||=
        to_dynamo_attribute_definition_type(@klass_or_sym) or raise InvalidTypeError.new("#{@klass_or_sym.inspect} cannot be used as an attribute definition type")
    end

    def dynamo_attribute_value_type_key
      @dynamo_attribute_value_type_key ||=
        to_dynamo_attribute_value_type_key(@klass_or_sym) or raise InvalidTypeError.new("#{@klass_or_sym.inspect} cannot be used as an attribute name type key")
    end


    # TODO Allow more elaborate mappings of attributes
    # Returns nil if the value is not valid in dynamo (nil, empty, etc)
    def dynamo_attribute(obj)
      dynamo_attribute_from_value dynamo_attribute_value(obj.send name)
    end
    def dynamo_attribute_from_value(attr_val)
      { dynamo_attribute_key => { dynamo_attribute_value_type_key => attr_val }} unless attr_val.nil?
    end

    # Returns the value to be set in the mapped object for this attribute, from
    # the returned dynamodb item hash
    def object_value(dynamo_data)
      dynamo_data[dynamo_attribute_key].send dynamo_attribute_value_type_key
    end

    private

    # TODO enforce ranges on these attributes
    def dynamo_attribute_value(val)
      case dynamo_attribute_value_type_key
      when :n
        val # TODO Determine ranges on numbers for dynamo
      when :ns
        val if val.any?
      when :s, :b
        val unless val.empty?
      when :ss, :bs
        x = val.select {|s| !s.empty? }
        x if x.any?
      end unless val == nil
    end

    def dynamo_attribute_key
      # TODO allow customization of dynamo field name
      name.to_s
    end

    def to_dynamo_attribute_definition_type(klass_or_sym)
      ret = to_dynamo_attribute_value_type_key(klass_or_sym, false)
      ret ? ret.to_s.upcase : nil
    end

    def to_dynamo_attribute_value_type_key(type, allow_array = true)
      symbol_to_dynamo_attribute_value_type_key(type, allow_array) || object_to_dynamo_attribute_value_type_key(type, allow_array)
    end

    # Handles symbol-style attribute types: :numeric, :string, :array_of_binaries, etc.
    def symbol_to_dynamo_attribute_value_type_key(type_obj, allow_array = true)
      SYMBOL_TYPES.merge(allow_array ? ARRAY_SYMBOL_TYPES : {})[type_obj] if type_obj.is_a?(Symbol)
    end

    # Handles object-style attribute types: Integer, [String], Numeric, etc.
    def object_to_dynamo_attribute_value_type_key(type_obj, allow_array = true)
      if type_obj.is_a?(Enumerable) && allow_array && type_obj.any?
        contained_type = to_dynamo_attribute_value_type_key(type_obj.first, false)
        (contained_type.to_s + 's').to_sym if contained_type
      else
        CLASS_TYPES.select {|klass, dynamo_type| type_obj.ancestors.include?(klass)}.values.first if type_obj.respond_to? :ancestors
      end
    end
  end
end
