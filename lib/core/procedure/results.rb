# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : result.rb
# License: Creative Commons Attribution
#
# Summary: The result of executing an entire test procedure.

require_relative 'result'

module Maadi
  module Procedure
    class Results
      # test_id (Integer) which lists the name of the step that the result is associated with
      # proc_id (String) procedure id which these results are linked to
      # source (String) application/instance name to which the results belong
      # results (Array of Result) array of the results of each step being executed
      attr_accessor :test_id, :proc_id, :source, :results, :key_id

      def initialize( test_id, proc_id, source, results )
        @test_id = test_id
        @proc_id = proc_id
        @source = source
        @key_id = -1

        @results = Array.new
        if results != nil
          if results.is_a?( Array )
           @results = results
          end
        end
      end

      def to_s
        return "#{test_id.to_s}:#{proc_id.to_s}"
      end

      def add_result( result )
        if result != nil
          if result.is_a?( Maadi::Procedure::Result )
            @results.push result
          end
        end
      end
    end
  end
end