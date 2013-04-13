# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : factory.rb
# License: Creative Commons Attribution
#
# Summary: This is an Extension to the Analyzer class which acts
#          as a factory for the Analyzer class.  It manages and
#          allows custom applications to be instantiated and loaded
#          from the local directory.

require_relative '../../core/analyzer/analyzer'
require_relative '../factory'

module Maadi
  module Analyzer
    class Analyzer

      def Analyzer::choices()
        self_name = self.name.gsub(/\w+::/, '')

        return Maadi::Factory.products(self_name)
      end

      def Analyzer::factory( type, messaging = true )
        self_name = self.name.gsub(/\w+::/, '')

        return Maadi::Factory.manufacture(self_name,type, messaging)
      end
    end
  end
end