# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : spreadsheet.rb
#
# Summary: This is a Spreadsheet Expert which currently is not
#          much more than a template

require_relative 'factory'
require_relative '../../core/helpers'


module Maadi
  module Expert
    class Spreadsheet < Expert

      def initialize
        super('Spreadsheet')
      end

      def domain
        return 'Spreadsheet'
      end

      def tests
        return Array.new
      end
    end
  end
end