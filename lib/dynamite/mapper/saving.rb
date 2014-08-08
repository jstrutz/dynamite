module Dynamite
  module Mapper
    module Saving
      def save!(obj)
        client.put_item(put_params(obj))
      end

      def put_params(obj)
        {
          table_name: table_name,
          item: dynamo_attributes_for_item(obj),
          return_values: "NONE"
        }
      end

      def dynamo_attributes_for_item(obj)
        attributes.values.inject({}) do |dynamo_attrs,attribute|
          dynamo_attrs.merge(attribute.dynamo_attribute(obj) || {})
        end
      end
    end
  end
end
