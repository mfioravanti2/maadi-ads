# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 10/16/2013
# File   : ADSStack.rb
#
# Summary: This is the Expert for an ADSStack

require_relative 'factory'
require_relative '../../core/helpers'
require_relative '../procedure/ConstraintConstant'
require_relative '../procedure/ConstraintSingleWord'
require_relative '../procedure/ConstraintSingleString'
require_relative '../procedure/ConstraintPickList'
require_relative '../procedure/ConstraintMultiPickList'
require_relative '../procedure/ConstraintMultiWord'
require_relative '../procedure/ConstraintRangedInteger'


module Maadi
  module Expert
    class ADSStack < Expert

      def initialize
        super('ADSStack')

        @tests = Array.new
        @has_stack = false
        @stack_size = 0

        @options['CREATE_RATIO'] = 1
        @options['PUSH_RATIO'] = 1
        @options['POP_RATIO'] = 1
        @options['ATINDEX_RATIO'] = 1
        @options['SIZE_RATIO'] = 1
        @options['DETAILS_RATIO'] = 1

        #@options['MAX_INTEGER'] = 1024                            # Smaller size for debugging
        @options['MAX_INTEGER'] = (2**(0.size * 8 -2) -1)         # Select the maximum size for a Fixnum

        @notes['CREATE_RATIO'] = 'Relative Ratio for CREATE commands (0 or less, ignore command type)'
        @notes['PUSH_RATIO'] = 'Relative Ratio for PUSH commands (0 or less, ignore command type)'
        @notes['POP_RATIO'] = 'Relative Ratio for POP commands (0 or less, ignore command type)'
        @notes['ATINDEX_RATIO'] = 'Relative Ratio for AT INDEX commands (0 or less, ignore command type)'
        @notes['SIZE_RATIO'] = 'Relative Ratio for SIZE commands (0 or less, ignore command type)'

        @notes['MAX_INTEGER'] = 'Maximum size of integers to attempt push on to the stack'
      end

      # returns (String) which the the domain that this expert specializes in
      def domain
        return 'ADS-STACK'
      end

      # prepare will setup the execution environment.  No tests will be executed but all required
      # resources and services will be prepared to execution.
      # return (bool) true if all of the components are read.
      def prepare
        super

        @test_list = @builder.tests

        @test_list.each do |item|
          if @options["#{item}_RATIO"].to_i >= 1
            1.upto(@options["#{item}_RATIO"].to_i) do
              @tests.push item
            end
          end
        end
      end

      # returns (Array of Strings) which lists all of the tests that the
      # expert currently supports, as various procedures are generated, different
      # tests become available or are not longer available.  The Stack expert is
      # partially stateful wrt constructing databases and tables.
      def tests
        if @model != nil
          #puts "MODEL: STACK-EXISTS=#{@model.get_value('STACK-EXISTS')}, STACK-SIZE=#{@model.get_value('STACK-SIZE')}"

          if @model.get_value('STACK-EXISTS') == true
            return @tests
          end
        end

        return %w(CREATE)

        #unless @has_stack
        #  return %w(CREATE)
        #end

        # all of the possible options, not all have been implemented.
        #%w( CREATE PUSH POP ATINDEX SIZE )
        return @tests
      end


      # determine if the item passed is a procedure
      # procedure (Any), determine if the object is a Maadi::Procedure::Procedure
      # return (bool) true if, the object is a Maadi::Procedure::Procedure
      def is_procedure?( procedure )
        if procedure != nil
          if procedure.is_a?( Maadi::Procedure::Procedure )
            return true
          end
        end

        return false
      end

      # determine if the item passed is a step
      # step (Any), determine if the object is a Maadi::Procedure::Step
      # return (bool) true if, the object is a Maadi::Procedure::Step
      def is_step?( step )
        if step != nil
          if step.is_a?( Maadi::Procedure::Step )
            return true
          end
        end

        return false
      end

      # build/update a procedure for a specified test
      #   this function will mark a procedure as complete when all of the possible options
      #   have been specified.  Procedures built are assumed to have been successfully executed
      #   on an application so the state model will reflect any changes or updates that are
      #   expected to occur
      # test (String) name of a test build or update
      # procedure (Maadi::Procedure::Procedure) test procedure to be modified
      #                                         setting the value to nil, will cause a new procedure
      #                                         to be instantiated
      # return (Maadi::Procedure::Procedure) the procedure that was constructed based on current information
      def procedure( test, procedure )
        if @builder != nil
          return @builder.procedure( test, procedure, self, @model )
        end

        return procedure
      end

    end
  end
end