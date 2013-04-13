# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : factory.rb
# License: Creative Commons Attribution
#
# Summary: This is an Extension to the Expert class which acts
#          as a factory for the Expert class.  It manages and
#          allows custom applications to be instantiated and loaded
#          from the local directory.

require_relative '../../core/expert/expert'
require_relative '../factory'

module Maadi
  module Expert
    class Expert

      def Expert::choices()
        self_name = self.name.gsub(/\w+::/, '')

        return Maadi::Factory.products(self_name)
      end

      def Expert::factory( type )
        self_name = self.name.gsub(/\w+::/, '')

        return Maadi::Factory.manufacture(self_name,type)
      end
    end
  end
end