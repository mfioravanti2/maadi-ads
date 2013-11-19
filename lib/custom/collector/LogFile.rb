# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : logfile.rb
#
# Summary: This is an Log File version of a Collector

require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Collector
    class LogFile < Collector

      def initialize
        super('LogFile')
        @readable = false

        t = Time.now
        @options['FILENAME'] = "Maadi-#{t.strftime('%Y%m%d%H%M%S')}.log"

        @notes['FILENAME'] = 'Filename of the log'
      end

      # prepare the collector;
      # if it is a database; connect to the database, validate the schema
      # if it is a log file; open the file for write only/append
      def prepare
        super
      end

      # log a message to the database
      # message (String) text message to be recorded in the database
      # return N/A
      def log_message( level, message )
        t = Time.now
        File.open( @options['FILENAME'], 'a') do |f|
          f.puts "#{t.strftime('%Y%m%d%H%M%S')}\tMESSAGE\t#{message}"
        end
      end

      # log all of the options from a Maadi::Generic::Generic object
      # generic (Generic) object to have all of it's options recorded in the database
      # return N/A
      def log_options( generic )
        if Maadi::Generic::Generic::is_generic?( generic )
          options = generic.options
          if options.length > 0
            t = Time.now
            File.open( @options['FILENAME'], 'a') do |f|
              options.each do |option|
                f.puts "#{t.strftime('%Y%m%d%H%M%S')}\tOPTION\t#{generic.type}\t#{generic.instance_name}\t#{option}\t#{generic.get_option(option)}"
              end
            end
          end
        end
      end

      # log a procedure to the database
      # procedure (Procedure) procedure to be recorded in the database
      def log_procedure( procedure )
        if Maadi::Procedure::Procedure::is_procedure?( procedure )
          t = Time.now
          File.open( @options['FILENAME'], 'a') do |f|
            f.puts "#{t.strftime('%Y%m%d%H%M%S')}\tPROCEDURE\t#{procedure.key_id}\t#{procedure.to_s}"

            procedure.steps.each do |step|
              f.puts "\tSTEP\t#{step.key_id}\t#{step.id.to_s}\t#{step.command}\t#{step.execute}"

              step.parameters.each do |parameter|
                f.puts "\tPARAMETER\t#{parameter.key_id}\t#{parameter.label}\t#{parameter.value.to_s}\t#{parameter.constraint.to_s}"
              end
            end

            procedure.comparisons.each do |comparison|
              f.puts "\tCOMPARE\t#{comparison.id}\t#{comparison.relationship}"
              comparison.steps.each do |item|
                f.puts "\t\tSTEP\t#{item.id}\t#{item.key_id}"
              end
            end
          end
        end
      end

      # log the results of a test procedure that was executed
      # application (Application) application that the test procedure was executed against
      # procedure (Procedure) test procedure that was executed
      # results (Results) test results from executing the procedure against the application under test
      def log_results( executable, procedure, results )
        if Maadi::Generic::Executable.is_executable?( executable ) and Maadi::Procedure::Procedure::is_procedure?( procedure ) and Maadi::Procedure::Results::is_results?( results )
          t = Time.now
          File.open( @options['FILENAME'], 'a') do |f|
            f.puts "#{t.strftime('%Y%m%d%H%M%S')}\tRESULTS\t#{results.key_id}\t#{results.source}\t#{executable.to_s}\t#{procedure.to_s}\t#{procedure.key_id}\t#{results.to_s}"

            results.results.each do |result|
              f.puts "\tRESULT\t#{result.key_id}\t#{result.step_key}\t#{result.step_name}\t#{result.target}\t#{result.status}\t#{result.type}\t#{result.data.to_s}"
            end
          end
        end
      end

      # teardown will remove all of the resources and services that were created specifically for this test.
      def teardown
        super
      end
    end
  end
end