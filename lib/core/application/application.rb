# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : application.rb
# License: Creative Commons Attribution
#
# Summary: The application is a general interface for real software under test,
#          this class should be extended to implement the calls that would be expected
#          to occur by executing a test procedure.

require_relative '../generic/executable'
require_relative '../helpers'

module Maadi
  module Application
    class Application < Maadi::Generic::Executable
      # type (String) is a convenient human readable label.
      def initialize(type)
        super(type)
      end

      def supported_domains
        return Array.new
      end

      def works_with?( domain )
        return supported_domains.include?( domain )
      end

      def execution_target
        return 'application'
      end

      def prepare
        Maadi::post_message(:More, "Application (#{@type}:#{@instance_name}) is ready")
        super
      end

      # teardown will remove all of the resources and services that were created specifically for this test.
      def teardown
        Maadi::post_message(:Less, "Application (#{@type}:#{@instance_name}) is NO longer ready")
        super
      end

      def self.is_application?( application )
        if application != nil
          if application.is_a?( Maadi::Application::Application )
            return true
          end
        end

        return false
      end
     end
  end
end