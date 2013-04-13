# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : factory.rb
# License: Creative Commons Attribution
#
# Summary: This is an Extension to the Collector class which acts
#          as a factory for the Collector class.  It manages and
#          allows custom database interfaces to be instantiated
#          and loaded from the local directory.

require_relative '../../core/collector/collector'
require_relative '../../core/collector/repository'
require_relative '../factory'

module Maadi
  module Collector

    class Collector

      def Collector::choices()
        self_name = self.name.gsub(/\w+::/, '')

        return Maadi::Factory.products(self_name)
      end

      def Collector::factory( type )
        self_name = self.name.gsub(/\w+::/, '')

        return Maadi::Factory.manufacture(self_name,type)
      end
    end
  end
end