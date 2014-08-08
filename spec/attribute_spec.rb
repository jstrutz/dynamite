require 'spec_helper'

describe Dynamite::Attribute do
  it "should initialize normally" do
    Dynamite::Attribute.new(:foo_count, Fixnum)
  end

  describe :dynamo_attribute_definition_type do
    it "should work with various expected valid given attribute types" do
      {
        'N' => [Numeric, Integer, :integer, Fixnum, :number, :numeric],
        'S' => [String, :string],
        'B' => [:binary],

      }.each do |expected_type, given_types|
        given_types.each do |given_type|
          Dynamite::Attribute.new(:foo, given_type).dynamo_attribute_definition_type.must_equal expected_type
        end
      end
    end

    it "should raise an exception for invalid attribute definition types" do
      [1, 'kablooie', [Integer], :array_of_ints].each do |given_type|
        result = nil
        -> {
          result = Dynamite::Attribute.new(:foo, given_type).dynamo_attribute_definition_type
        }.must_raise Dynamite::Attribute::InvalidTypeError, "#{given_type.inspect} didn't raise an InvalidTypeError; result was #{result.inspect}"
      end
    end
  end

  describe :dynamo_attribute_value_type_key do
    it "should work with various expected valid given attribute types" do
      {
        n: [Numeric, Integer, :integer, Fixnum, :number, :numeric],
        s: [String, :string],
        b: [:binary],
        ns: [:ints, :numbers, [Integer], [Numeric], :array_of_numbers],
        ss: [:strings, [String], :array_of_strings],
        bs: [:binaries, :array_of_binaries, [:binary]],
      }.each do |expected_type, given_types|
        given_types.each do |given_type|
          Dynamite::Attribute.new(:foo, given_type).dynamo_attribute_value_type_key.must_equal expected_type
        end
      end
    end

    it "should raise an exception for invalid attribute name key types" do
      [1, 'kablooie', [Module], :array_of_cheeses].each do |given_type|
        result = nil
        -> {
          result = Dynamite::Attribute.new(:foo, given_type).dynamo_attribute_value_type_key
        }.must_raise Dynamite::Attribute::InvalidTypeError, "#{given_type.inspect} didn't raise an InvalidTypeError; result was #{result.inspect}"
      end
    end
  end
end
