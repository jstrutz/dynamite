module Dynamite
  module Mapper
    module TableManagement
      def table_exists?
        client.describe_table(table_name: table_name)
        true
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException
        false
      end

      def delete_table!
        client.delete_table(table_name: table_name)
      end

      def create_table!
        client.create_table(dynamo_table_schema)
      end

      def dynamo_table_schema
        {
          attribute_definitions: build_dynamo_table_attribute_definitions,
          table_name: table_name,
          key_schema: build_dynamo_table_key_schema,
          provisioned_throughput: build_dynamo_table_throughput
        }
      end
    private

      def build_dynamo_table_attribute_definitions
        @attributes.values.select {|attr| [@hash_key, @range_key].include?(attr.name)}.map do |attr|
          { attribute_name: attr.name.to_s, attribute_type: attr.dynamo_attribute_definition_type }
        end
      end

      def build_dynamo_table_key_schema
        raise "Must declare at least a hash_key" unless @hash_key
        # TODO This should raise a custom exception class
        [[@hash_key, 'HASH'],[@range_key, 'RANGE']].map do |key, key_type|
          {
            attribute_name: @attributes.fetch(key) { raise "Missing attribute #{key.to_s} for key"}.name.to_s,
            key_type: key_type
          } if key
        end.compact
      end

      # TODO Add DSL methods to declare throughput provisions
      def build_dynamo_table_throughput
        {
          read_capacity_units: 50,
          write_capacity_units: 10,
        }
      end
    end
  end
end
