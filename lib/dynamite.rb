require "dynamite/attribute"
require "dynamite/mapper"
require "dynamite/version"

module Dynamite

  def self.config=(settings)
    @config = settings
  end

  def self.config
    @config
  end
end
