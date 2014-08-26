module Dynamite
  class SecondaryIndex
    attr_reader :attribute_names
    attr_reader :kind

    def initialize(attribute_names, options = {})
      @attribute_names = Array(attribute_names)
      @options = options
      @kind = options.fetch(:kind) { :global }
      @projection = options.fetch(:projection) { :all }
      @projection_keys = Array(options[:projection_keys])

    end

    def plural_finder_method_name
      ["find", "all", "by", @attribute_names.join('_and_')].join('_')
    end

    def single_finder_method_name
      ["find", "by", @attribute_names.join('_and_')].join('_')
    end

    def dynamo_index_name
      @attribute_names.join('_')
    end

    def table_definition
      {
        index_name: dynamo_index_name,
        key_schema: attribute_names.zip(['HASH','RANGE']).map do |name, key_type|
          {
            attribute_name: name.to_s,
            key_type: key_type
          }
        end,
        projection: {
          projection_type: @projection.to_s.upcase,
          non_key_attributes: (@projection_keys.map(:to_s) if @projection_keys.any?)
        },
        # TODO Provide options for this
        provisioned_throughput: {
          read_capacity_units: 1,
          write_capacity_units: 1,
        }
      }
    end
  end
end
