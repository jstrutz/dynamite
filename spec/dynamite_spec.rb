require 'spec_helper'

describe Dynamite do
  describe :config do
    it "should accept configuration settings" do
      Dynamite.config = {
        aws_access_id: 'abcde',
        aws_secret_key: 'xxyyzz',
        host: 'localhost',
        port: 8080,
        protocol: "https",
        realm: 'abcde'
      }
    end

    it "should not allow unknown configuration keys"
  end
end
