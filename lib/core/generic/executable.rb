# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : executable.rb
# License: Creative Commons Attribution
#
# Summary: This is a general interface class which allows procedures to
#          be executed and results to be returned.  This interface will allow
#          procedures to be tested (by individual step) to determine if they
#          can be executed by the target application.  execution_target and
#          supported_step? should be overridden by any derived class.

require_relative 'generic'
require_relative '../procedure/procedure'
require_relative '../procedure/results'

module Maadi
  module Generic
    class Executable < Generic

      # type (String) is a convenient human readable label.
      def initialize(type)
        super(type)
      end

      # execute a desired test procedure against the current application
      # test_id (Integer) id to represent an individual test procedure execution (the same procedure may be
      #                   executed multiple times so we need a way to distinguish between those instances)
      # procedure (Procedure) procedure which is to be added to the scheduler
      # return (Result) return the results of the execution of the test procedure
      def execute( test_id, procedure )
        results = Maadi::Procedure::Results.new( test_id.to_i, 0,  'Generic::Executable', nil )

        if procedure != nil
          if procedure.is_a?( Maadi::Procedure::Procedure )
            results.proc_id = procedure.id
          end
        end

        return results
      end

      def default_target
        return 'any'
      end

      def execution_target
        return default_target
      end

      def supports_procedure?( procedure )
        if procedure != nil
          if procedure.is_a?( Maadi::Procedure::Procedure )
            procedure.steps.each do | step |
              if step.target == execution_target || step.target == default_target
                unless supports_step?( step )
                  return false
                end
              end
            end

            return true
          end
        end

        return false
      end

      def supports_step?( step )
        if step != nil
          if step.is_a?( Maadi::Procedure::Step )
            return true
          end
        end

        return false
      end
     end
  end
end