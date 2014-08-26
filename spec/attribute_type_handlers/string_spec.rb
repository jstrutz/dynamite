require 'spec_helper'

describe Dynamite::AttributeTypeHandlers::String do
  describe :handles_type? do
    it "should handle all expected string types" do
      [:string, :uuid, String].each do |string_type|
        Dynamite::AttributeTypeHandlers::String.handles_type?(string_type).must_equal true, "Failed to handle #{string_type.inspect}"
      end
    end

    it "should not handle non-string types" do
      [:number, 'abcde', 1, Object].each do |non_string_type|
        Dynamite::AttributeTypeHandlers::String.handles_type?(non_string_type).wont_equal true,
          "Improperly claimed to handle #{non_string_type.inspect}"
      end
    end
  end
end
