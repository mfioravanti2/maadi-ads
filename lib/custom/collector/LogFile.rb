# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : LogFile.rb
# License: Creative Commons Attribution
#
# Summary: This is an Log File version of a Collector

require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Collector
    class LogFile < Collector

      def initialize
        super('LogFile')
        @readable = true
        @file = nil

        t = Time.now
        @options['FILENAME'] = "Maadi-#{t.strftime('%Y%m%d%H%M%S')}.log"

        @notes['FILENAME'] = 'Filename of the log'

      end

      # prepare the collector;
      # if it is a database; connect to the database, validate the schema
      # if it is a log file; open the file for write only/append
      def prepare
        t = Time.now

        @file = File.open( @options['FILENAME'], 'w')

        super
      end

      # log a message to the database
      # message (String) text message to be recorded in the database
      # return N/A
      def log_message( level, message )
        t = Time.now
        @file.puts "#{t.strftime('%Y%m%d%H%M%S')}\tMESSAGE\t#{message}"
      end

      # log a procedure to the database
      # procedure (Procedure) procedure to be recorded in the database
      def log_procedure( procedure )
        if procedure != nil
          if procedure.is_a?( Maadi::Procedure::Procedure )
            t = Time.now
            @file.puts "#{t.strftime('%Y%m%d%H%M%S')}\tPROCEDURE\t#{procedure.to_s}"

            procedure.steps.each do |step|
              @file.puts "\tSTEP\t#{step.id.to_s}\t#{step.command}\t#{step.execute}"

              step.parameters.each do |parameter|
                @file.puts "\tPARAMETER\t#{parameter.label}\t#{parameter.value.to_s}\t#{parameter.constraint.to_s}"
              end
            end
          end
        end
      end

      # log the results of a test procedure that was executed
      # application (Application) application that the test procedure was executed against
      # procedure (Procedure) test procedure that was executed
      # results (Results) test results from executing the procedure against the application under test
      def log_results( application, procedure, results )
        if (application != nil) && (procedure != nil) && (results != nil)
          if (application.is_a?(Maadi::Application::Application)) && ( procedure.is_a?( Maadi::Procedure::Procedure ) ) && ( results.is_a?( Maadi::Procedure::Results ) )
            t = Time.now
            @file.puts "#{t.strftime('%Y%m%d%H%M%S')}\tRESULTS\t#{results.source}\t#{application.to_s}\t#{procedure.to_s}\t#{results.to_s}"

            results.results.each do |result|
              @file.puts "\tRESULT\t#{result.step}\t#{result.target}\t#{result.status}\t#{result.type}\t#{result.data.to_s}"
            end
          end
        end
      end

      # teardown will remove all of the resources and services that were created specifically for this test.
      def teardown
        @file.close
        super
      end
    end
  end
end