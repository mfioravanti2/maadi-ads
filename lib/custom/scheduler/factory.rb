# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : factory.rb
# License: Creative Commons Attribution
#
# Summary: This is an Extension to the Monitor class which acts
#          as a factory for the Monitor class.  It manages and
#          allows custom operating system monitors to be
#          instantiated and loaded from the local directory.

require_relative '../../core/scheduler/scheduler'
require_relative '../factory'

module Maadi
  module Scheduler
    class Scheduler

      def Scheduler::choices()
        self_name = self.name.gsub(/\w+::/, '')
        return Maadi::Factory.products(self_name)
      end

      def Scheduler::factory( type )
        self_name = self.name.gsub(/\w+::/, '')

        return Maadi::Factory.manufacture(self_name,type)
      end
    end
  end
end