# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : organizer.rb
#
# Summary: The organizer will collect and population the test procedures
#          according to it's plan.  An example organizer would be one that
#          perform all-pairs testing, cause-effect graphing, etc.

require_relative '../generic/generic'
require_relative '../procedure/procedure'
require_relative '../helpers'

module Maadi
  module Organizer
    class Organizer < Maadi::Generic::Generic
      # type (String) is a convenient human readable label.
      def initialize(type)
        super(type)
        @runs = 0
      end

      def supported_domains
        return Array.new
      end

      def works_with?( domain )
        return supported_domains.include?( domain )
      end

      # prepare the organizer;
      def prepare
        Maadi::post_message(:More, "Organizer (#{@type}) is ready")
        super
      end

      # return (bool) true if all of the components are read.
      def available_parameters( params, runs )
        @runs = runs

        Maadi::post_message(:More, "Organizer (#{@type}) Parameters are ready")
        return true
      end

      def select_test( tests )
        if tests.instance_of?(Array)
          if tests.length > 0
            return tests[0]
          end
        end

        return ''
      end

      def populate_parameters!( procedure )

      end

      # teardown will remove all of the resources and services that were created specifically for this test.
      def teardown
        Maadi::post_message(:Less, "Organizer (#{@type}) is NO longer ready")
        super
      end

      def self.is_organizer?( organizer )
        if organizer != nil
          if organizer.is_a?( Maadi::Organizer::Organizer )
            return true
          end
        end

        return false
      end
    end
  end
end