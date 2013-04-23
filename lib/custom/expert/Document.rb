# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : document.rb
#
# Summary: This is a Document Expert which currently is not
#          much more than a template

require_relative 'factory'
require_relative '../../core/helpers'


module Maadi
  module Expert
    class Document < Expert

      def initialize
        super('Document')
      end

      def domain
        return 'Document'
      end

      def tests
        return Array.new
      end

    end
  end
end