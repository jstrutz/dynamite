require_relative './mapper/dsl'
require_relative './mapper/client'
require_relative './mapper/primary_key_finders'
require_relative './mapper/saving'
require_relative './mapper/table_management'

module Dynamite
  module Mapper

    class DuplicateAttributeError < StandardError; end
    class InvalidAttributeTypeError < StandardError; end

    def self.included(base)
      base.extend Mapper::Client
      base.extend Mapper::DSL
      base.extend Mapper::TableManagement
      base.extend Mapper::PrimaryKeyFinders
      base.extend Mapper::Saving
    end
  end
end
