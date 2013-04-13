# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : Example.rb
# License: Creative Commons Attribution
#
# Summary: This is an Example (i.e. Toy) Monitor which can be
#          used for testing or as a template

require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Scheduler
    class FIFO < Scheduler

      def initialize
        super('FIFO')
      end
    end
  end
end