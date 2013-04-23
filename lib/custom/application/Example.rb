# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : Example.rb
#
# Summary: This is an Example (i.e. Toy) Application which can be
#          used for testing or as a template

require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Application
    class Example < Application

      def initialize
        super('Example')
      end

      def supported_domains
        return %w(SQL Spreadsheet Document)
      end
    end
  end
end