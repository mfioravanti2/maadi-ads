# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : collector.rb
# License: Creative Commons Attribution
#
# Summary: The collector is a component which is able to record messages,
#          procedures and results.  It is a data repository which may or may not
#          be queriable.  It could be implemented as a database or a simple log
#          file.

require_relative '../generic/generic'
require_relative '../procedure/result'
require_relative '../procedure/procedure'
require_relative '../helpers'

module Maadi
  module Collector
    class Collector < Maadi::Generic::Generic
      # type (String) is a convenient human readable label.
      def initialize(type)
        super(type)
        @readable = false
        @levels = { :Warn => 'WARN', :Info => 'INFO', :More => 'MORE', :Less => 'LESS', :None => 'NORM'}
      end

      # determine if the collector is readable (i.e. are other components able to issue queries, or
      # is it more like a log where things are recorded but it is not trivially queriable)
      # return (bool) true if the collector is readable
      def is_readable?
        return @readable
      end

      # prepare the collector;
      # if it is a database; connect to the database, validate the schema
      # if it is a log file; open the file for write only/append
      def prepare
        Maadi::post_message(:More, "Collector (#{@type}) is ready")
        super
      end

      def level_text( level )
        return @levels[level]
      end

      # log a message to the database
      # message (String) text message to be recorded in the database
      # return N/A
      def log_message( level, message )

      end

      # log a procedure to the database
      # procedure (Procedure) procedure to be recorded in the database
      def log_procedure( procedure )

      end

      # log the results of a test procedure that was executed
      # application (Application) application that the test procedure was executed against
      # procedure (Procedure) test procedure that was executed
      # results (Results) test results from executing the procedure against the application under test
      def log_results( application, procedure, results )

      end

      # teardown will remove all of the resources and services that were created specifically for this test.
      def teardown
        Maadi::post_message(:Less, "Collector (#{@type}) is NO longer ready")
        super
      end
    end
  end
end