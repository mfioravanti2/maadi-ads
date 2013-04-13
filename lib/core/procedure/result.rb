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
      # step (String) which lists the name of the step that the result is associated with
      # target (String) which lists the target of the step (either Monitor, Application or Tasker)
      # data (String) which represents the actual result of the step
      # type (String) type of data which is being stored
      # status (String) the status of the result (SUCCESS, FAIL, EXCEPTION, UNKNOWN, etc.)
      attr_accessor :step, :target, :data, :type, :status, :key_id

      def initialize(step, target, data, type, status = 'UNKNOWN')
        @step = step
        @target = target
        @data = data
        @type = type
        @status = status
      end

      def to_s
        return @step.to_s
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