require 'spec_helper'

describe Dynamite::AttributeTypeHandlers::Number do
  describe :handles_type? do
    it "should handle all expected number types" do
      [:number, :integer, Fixnum, Numeric, Integer].each do |number_type|
        Dynamite::AttributeTypeHandlers::Number.handles_type?(number_type).must_equal true, "Failed to handle #{number_type.inspect}"
      end
    end

    it "should not handle non-number types" do
      [:string, 'abcde', 1, Object, String].each do |non_number_type|
        Dynamite::AttributeTypeHandlers::Number.handles_type?(non_number_type).wont_equal true,
          "Improperly claimed to handle #{non_number_type.inspect}"
      end
    end
  end
end
