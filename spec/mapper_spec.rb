require 'spec_helper'

describe Dynamite::Mapper do
  describe :maps do
    it "should allow a mapped class" do
      class Foo; end
      class Bar
        include Dynamite::Mapper

        maps Foo
      end
      Bar.mapped_class.must_equal Foo
    end
  end

  describe :table_name do
    it "should infer the table name from the class name" do
      module Container
        class Bar
          include Dynamite::Mapper
        end
      end

      Container::Bar.table_name.must_equal "bar"
    end

    it "should strip the 'Mapper' string from the end of the inferred table_name" do
      class BarMapper
        include Dynamite::Mapper
      end

      BarMapper.table_name.must_equal "bar"
    end

    it "should allow overriding of the table name" do
      class Bar
        include Dynamite::Mapper

        table_name :foo
      end
      Bar.table_name.must_equal "foo"
    end

  end

  describe :attribute do
    it "should allow the declaration of an attribute" do
      class Foo
        include Dynamite::Mapper
      end
      Foo.attribute :name, String
    end

    it "should raise an exception if the attribute has already been declared" do
      x = Class.new do
        include Dynamite::Mapper
      end
      x.attribute :name, String
      proc { x.attribute 'name', String }.must_raise Dynamite::Mapper::DuplicateAttributeError
    end

  end

  describe :dynamo_table_schema do
    it "should create a table with given attributes" do
      m = Class.new do
        include Dynamite::Mapper
        table_name "shoes"
        attribute :id, String
        attribute :name, String
        hash_key :id
      end

      m.dynamo_table_schema.tap do |s|
        s.must_respond_to :[]
        s[:attribute_definitions].tap do |attrs|
          attrs.length.must_equal 1
          attrs.first[:attribute_name].must_equal 'id'
          attrs.first[:attribute_type].must_equal 'S'
        end
        s[:key_schema].tap do |keys|
          keys.wont_be_empty
          # TODO test more of the key schema contents
        end
      end
    end

    it "should raise an error if no hash_key is defined" do
      m = Class.new do
        include Dynamite::Mapper
        table_name "shoes"
        attribute :id, String
      end

      -> { m.dynamo_table_schema }.must_raise RuntimeError
    end
  end

  describe :save_and_find do
    it "should be able to save an item" do
      obj_class = Struct.new(:id, :name)
      obj_mapper = Class.new do
        include Dynamite::Mapper
        maps obj_class
        table_name "obj2"
        attribute :id, String
        attribute :name, String
        hash_key :id
      end
      Dynamite.config = {
        access_key_id: 'abcde',
        secret_access_key: 'xxyyzz',
        endpoint: "http://localhost:8000",
        region: 'abcde'
      }
      obj_mapper.delete_table! if obj_mapper.table_exists?
      obj_mapper.create_table!
      # TODO Assert table exists
      obj = obj_class.new(SecureRandom.uuid, "Hello there!")
      obj_mapper.find(obj.id).must_equal nil
      obj_mapper.save!(obj)
      returned_obj = obj_mapper.find(obj.id)
      returned_obj.wont_equal nil

      # Change the object, and ensure the changes are store
      # TODO This is assuming strong consistency, which should be added
      # as a config option
      obj.name = "Goodbye"
      obj_mapper.save!(obj)
      obj_mapper.find(obj.id).name.must_equal "Goodbye"
    end
  end
end
