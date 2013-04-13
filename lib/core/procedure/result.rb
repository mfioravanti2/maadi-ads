# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : result.rb
# License: Creative Commons Attribution
#
# Summary: The Result of Executing a specific step within a Test Procedure.

module Maadi
  module Procedure
    class Result
      # step (Step) reference to a step object
      # data (String) which represents the actual result of the step
      # type (String) type of data which is being stored
      # status (String) the status of the result (SUCCESS, FAIL, EXCEPTION, UNKNOWN, etc.)
      attr_accessor :step, :step_name, :step_key, :target, :data, :type, :status, :key_id

      def initialize(step, data, type, status = 'UNKNOWN')
        if step != nil
          @step = step
          @step_name = @step.to_s
          @target = @step.target
          @step_key = @step.key_id
        else
          @step_name = ''
          @target = ''
          @step_key = -1
        end

        @data = data
        @type = type
        @status = status
      end

      def to_s
        return @step_name
      end

      def self.is_result?( result )
        if result != nil
          if result.is_a?( Maadi::Procedure::Result )
            return true
          end
        end

        return false
      end
    end
  end
end