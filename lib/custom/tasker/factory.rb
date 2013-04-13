# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : factory.rb
# License: Creative Commons Attribution
#
# Summary: This is an Extension to the Tasker class which acts
#          as a factory for the Tasker class.  It manages and
#          allows custom operating system monitors to be
#          instantiated and loaded from the local directory.

require_relative '../../core/tasker/tasker'
require_relative '../factory'

module Maadi
  module Tasker
    class Tasker

      def Tasker::choices()
        self_name = self.name.gsub(/\w+::/, '')
        return Maadi::Factory.products(self_name)
      end

      def Tasker::factory( type )
        self_name = self.name.gsub(/\w+::/, '')

        return Maadi::Factory.manufacture(self_name,type)
      end
    end
  end
end