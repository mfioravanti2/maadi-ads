# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 10/16/2013
# File   : ADSStack.rb
#
# Summary: This is the Expert for an ADSStack

require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Expert
    class ADSAxiomaticStack < Expert

      def initialize
        super('ADSAxiomaticStack')

        @tests = Array.new
        @has_stack = false
        @stack_size = 0

        @options['CREATE_RATIO'] = 1
        @options['PUSH_RATIO'] = 1
        @options['POP_RATIO'] = 1
        @options['ATINDEX_RATIO'] = 1
        @options['SIZE_RATIO'] = 1
        @options['DETAILS_RATIO'] = 1


        @options['PUSHPOP_RATIO'] = 1                              #axiom: stack = stack.pop(stack.push(Object))
        @options['PUSHPOPSIZE_RATIO'] = 1                          #axiom: stack.size() = stack.pop(stack.push(Object)).size()
        @options['NEWSTACKINDEX_RATIO'] = 1                        #axoim:  (new stack()).index(0) = error
        @options['NEWSTACKSIZE_RATIO'] = 1                         #axoim: (new stack()).size() = 0

        #@options['MAX_INTEGER'] = 1024                            # Smaller size for debugging
        @options['MAX_INTEGER'] = (2**(0.size * 8 -2) -1)          # Select the maximum size for a Fixnum

        @notes['CREATE_RATIO'] = 'Relative Ratio for CREATE commands (0 or less, ignore command type)'
        @notes['PUSH_RATIO'] = 'Relative Ratio for PUSH commands (0 or less, ignore command type)'
        @notes['POP_RATIO'] = 'Relative Ratio for POP commands (0 or less, ignore command type)'
        @notes['ATINDEX_RATIO'] = 'Relative Ratio for AT INDEX commands (0 or less, ignore command type)'
        @notes['SIZE_RATIO'] = 'Relative Ratio for SIZE commands (0 or less, ignore command type)'
        @notes['DETAILS_RATIO'] = 'Relative Ratio for DETAILS commands (0 or less, ignore command type)'

        @notes['PUSHPOP_RATIO'] = 'Relative Ratio for PUSH, POP sequence of commands (0 or less, ignore command type)'
        @notes['PUSHPOPSIZE_RATIO'] = 'Relative Ratio for PUSH, POP, SIZE commands (0 or less, ignore command type)'
        @notes['NEWSTACKINDEX_RATIO'] = 'Relative Ratio for CREATE, INDEX commands (0 or less, ignore command type)'
        @notes['NEWSTACKSIZE_RATIO'] = 'Relative Ratio for CREATE, SIZE commands (0 or less, ignore command type)'

        @notes['MAX_INTEGER'] = 'Maximum size of integers to attempt push on to the stack'
      end

      # returns (String) which the the domain that this expert specializes in
      def domain
        return 'ADS-AXIOMATIC-STACK'
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
      # tests become available or are not longer available.
      def tests
        if @model != nil

          if @model.get_value('STACK-EXISTS') == true
            return @tests
          end
        end

        return %w(CREATE)
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