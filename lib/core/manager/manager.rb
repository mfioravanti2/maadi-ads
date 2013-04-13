# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : maadi.rb
# License: Creative Commons Attribution
#
# Summary: The Manager class manages and drives the HiVAT test work flows.

require_relative '../collector/collector'
require_relative '../controller/controller'
require_relative '../analyzer/analyzer'
require_relative '../helpers'

module Maadi
  module Manager
    class Manager

      # collector (Collector) is an object that will be used to store the test procedures and results
      # runs (Integer) is the number of runs that will be executed.
      # analyzer (Analyzer) is an object that analyze the results which are stored in the collector
      def initialize( collectors, controller, analyzer )
        @collectors = collectors
        @analyzer = analyzer

        t = Time.now
        @test_id = "HiVAT-#{t.strftime('%Y%m%d%H%M%S')}"

        @controller = controller
        @is_prepared = false
      end

      def test_id
        return @test_id
      end

      # prepare will setup the execution environment.  No tests will be executed but all required
      # resources and services will be prepared to execution.
      # return (bool) true, if all of the components are ready to be executed.
      def prepare
        # by default we are not ready.
        @is_prepared = false

        # collectors should be prepared before anything else.
        @collectors.each do |collector|
          if !collector.is_ready?
            if !collector.prepare
              if !collector.is_ready?
                return false
              end
            end
          end
        end

        if @controller.prepare
          Maadi::post_message(:More, 'Manager is ready')
          @is_prepared = true
        end
      end

      def is_prepared?
        return @is_prepared
      end

      # start will begin collecting the test procedures, passing the test procedures to the applications interfaces for
      # execution, and collect the results.
      def start
        if @is_prepared
          Maadi::post_message(:Info, 'Manager started')
          done = @controller.start
          Maadi::post_message(:Info, 'Manager stopped')
        end
      end

      # perform the post test analysis and generate the test report.
      def report
        @analyzer.report( @collectors )
      end

      # teardown will remove all of the resources and services that were created specifically for this test.
      def teardown
        @controller.teardown
        @collectors.each { |collector| collector.teardown }
        @is_prepared = false
        Maadi::post_message(:Less, 'Manager is NO longer ready')
      end

      def report_name

      end

      def self.is_manager?( manager )
        if manager != nil
          if manager.is_a?( Maadi::Manager::Manager )
            return true
          end
        end

        return false
      end
    end
  end
end