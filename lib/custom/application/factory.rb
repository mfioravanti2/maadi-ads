# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : factory.rb
# License: Creative Commons Attribution
#
# Summary: This is an Extension to the Application class which acts
#          as a factory for the Application class.  It manages and
#          allows custom applications to be instantiated and loaded
#          from the local directory.

require_relative '../../core/application/application'
require_relative '../factory'

module Maadi
  module Application
    class Application

      def Application::choices()
        self_name = self.name.gsub(/\w+::/, '')

        return Maadi::Factory.products(self_name)
      end

      def Application::factory( type )
        self_name = self.name.gsub(/\w+::/, '')

        return Maadi::Factory.manufacture(self_name,type)
      end
    end
  end
end