# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : Example.rb
# License: Creative Commons Attribution
#
# Summary: This is a Comparison Analyzer which compares the results from
#          multiple applications and flags deviations as potential failures.

require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Analyzer
    class Comparison < Analyzer

      def initialize
        super('Comparison')
      end
    end
  end
end