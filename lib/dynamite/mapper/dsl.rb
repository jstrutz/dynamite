module Dynamite
  module Mapper
    module DSL
      attr_reader :mapped_class
      # attr_accessor :table_name

      def table_name(name=nil)
        @overridden_table_name = name.to_s if name
        @overridden_table_name || infer_table_name(self.name)
      end

      def maps(klass)
        @mapped_class = klass
      end

      def attribute(name, klass, opts = {})
        raise DuplicateAttributeError.new("#{name.to_s} has already been defined") if attributes[name.to_sym]
        attributes[name.to_sym] = Attribute.new(name, klass, opts)
      end

      def hash_key(attribute_name)
        @hash_key = attribute_name
      end

      def range_key(attribute_name)
        @range_key = attribute_name
      end
    private
      def attributes
        @attributes ||= {}
      end

      def infer_table_name(class_name)
        # TODO Use ActiveSupport to make this a bit more robust
        class_name.split(':').last.downcase.gsub(/mapper$/,'')
      end

    end
  end
end
