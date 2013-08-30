
require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Application
    class RubyStack < Application

      def initialize
        super('RubyStack')
      end

      def supported_domains
        return %w(ADS-STACK)
      end
    end
  end
end