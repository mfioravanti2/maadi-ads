
require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Application
    class JavaStack < Application

      def initialize
        super('JavaStack')
      end

      def supported_domains
        return %w(ADS-STACK)
      end
    end
  end
end