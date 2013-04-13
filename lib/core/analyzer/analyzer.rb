# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : analyzer.rb
# License: Creative Commons Attribution
#
# Summary: The Analyzer will interact with the Collector to analyze the
#          test results and generate a test report.

require_relative '../generic/generic'
require_relative '../collector/repository'

module Maadi
  module Analyzer
    class Analyzer < Maadi::Generic::Generic
      # type (String) is a convenient human readable label.
      def initialize(type)
        super(type)

        @repositories = Array.new
      end

      # prepare will setup the execution environment.  No tests will be executed but all required
      # resources and services will be prepared to execution.
      # return (bool) true if all of the components are read.
      def prepare
        Maadi::post_message(:More, "Analyzer (#{@type}) is ready")
        super
      end

      # access the defined collector and generate a report
      # collector (Collector) repository for results analysis
      def report( collectors )
        if collectors != nil
          if collectors.instance_of?( Array )
            collectors.each do |collector|
              if Maadi::Collector::is_repository?( collector )
                @repositories.push collector
              end
            end
          end
        end
      end

      # return the name of the report that was generated.
      def report_name
        return 'Report ID'
      end

      # teardown will remove all of the resources and services that were created specifically for this test.
      def teardown
        Maadi::post_message(:Less, "Analyzer (#{@type}) is NO longer ready")
        super
      end

      def self.is_analyzer?( analyzer )
        if analyzer != nil
          if analyzer.is_a?( Maadi::Analyzer::Analyzer )
            return true
          end
        end

        return false
      end
    end
  end
end