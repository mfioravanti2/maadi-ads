# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : factory.rb
#
# Summary: This is an Extension to the Organizer class which acts
#          as a factory for the Organizer class.  It manages and
#          allows custom organizers to be instantiated and loaded
#          from the local directory.

require_relative '../../core/organizer/organizer'
require_relative '../factory'

module Maadi
  module Organizer
    class Organizer

      def Organizer::choices()
        self_name = self.name.gsub(/\w+::/, '')
        return Maadi::Factory.products(self_name)
      end

      def Organizer::factory( type )
        self_name = self.name.gsub(/\w+::/, '')

        return Maadi::Factory.manufacture(self_name,type)
      end
    end
  end
end