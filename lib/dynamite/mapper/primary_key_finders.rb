module Dynamite
  module Mapper
    module PrimaryKeyFinders
      def find(key, opts = {})
        resp = client.get_item(get_params(key))
        vivify_mapped_class(resp.item) if resp.item
      end

      def get_params(key)
        {
          table_name: table_name,
          key: hash_key_attribute.dynamo_attribute_from_value(key)
        }
      end

      def hash_key_attribute
        attributes[@hash_key]
      end
    private
      def vivify_mapped_class(db_data)
        obj = @mapped_class.new
        attributes.values.each do |attr|
          obj.send attr.name.to_s + "=", attr.object_value(db_data)
        end
        obj
      end

    end
  end
end
