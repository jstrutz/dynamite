require 'spec_helper'

describe Dynamite::AttributeTypeHandlers::Time do
  describe :handles_type? do
    it "should handle all expected time types" do
      [:time, :timestamp, Time].each do |time_type|
        Dynamite::AttributeTypeHandlers::Time.handles_type?(time_type).must_equal true, "Failed to handle #{time_type.inspect}"
      end
    end

    it "should not handle non-number types" do
      [:string, 'abcde', 1, Object, String, Integer].each do |non_time_type|
        Dynamite::AttributeTypeHandlers::Time.handles_type?(non_time_type).wont_equal true,
          "Improperly claimed to handle #{non_time_type.inspect}"
      end
    end
  end

  describe :inherited do
    it "should register with AttributeTypeHandler's #handlers list" do

    end
  end

  describe :dynamo_attribute do
    it "should convert times to unix timestamp integers" do
      attr = Dynamite::Attribute.new(:created_at, :time)
      handler = Dynamite::AttributeTypeHandlers::Time.new(attr)
      time_value = Time.now
      obj = OpenStruct.new(created_at: time_value)
      expected = { 'created_at' => time_value.to_i.to_s }
      handler.dynamo_attribute(obj).must_equal expected
    end

  end

  describe :set_object_attribute! do
    it "should set dynamo table data in the object correctly" do
      attr = Dynamite::Attribute.new(:created_at, :time)
      handler = Dynamite::AttributeTypeHandlers::Time.new(attr)
      time_value = Time.now
      # dynamo_table = [OpenStruct.new(n: time_value.to_i.to_s)]
      # dynamo_record = {'created_at' => { :n => time_value.to_i.to_s }}
      dynamo_record = {'created_at' => time_value.to_i.to_s}
      obj = OpenStruct.new
      attr.set_object_attribute!(obj, dynamo_record)
      obj.created_at.to_i.must_equal time_value.to_i
    end
  end
end
