# Author : Scott Forest Hull II (shull2013@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 09/26/2013
# File   : AlgebraicADSStack.rb
#
# Summary: This is an extension of the ADSStack class that utilizes
#          various tests for axioms listed.
require_relative 'factory'
require_relative '../../core/helpers'
require_relative '../procedure/ConstraintConstant'
require_relative '../procedure/ConstraintSingleWord'
require_relative '../procedure/ConstraintSingleString'
require_relative '../procedure/ConstraintPickList'
require_relative '../procedure/ConstraintMultiPickList'
require_relative '../procedure/ConstraintMultiWord'
require_relative '../procedure/ConstraintRangedInteger'
require_relative 'ADSStack'

module Maadi
  module Expert
    class AlgebraicADSStack < ADSStack

      def initialize
        super('AlgebraicADSStack')

        #Options originally from  ADSStack are taken care of above.
        #Will need extra specification for experts.

        #axiom: stack = stack.pop(stack.push(Object))
        @options['PUSHPOP_RATIO'] = 1

        #axiom: stack.size() = stack.pop(stack.push(Object)).size()
        @options['PUSHPOPSIZE_RATIO'] = 1

        #axoim:  (new stack()).index(0) = error
        @options['NEWSTACKINDEX_RATIO'] = 1

        #axoim: (new stack()).size() = 0
        @options['NEWSTACKSIZE_RATIO'] = 1

      end

      # prepare will setup the execution environment.  No tests will be executed but all required
      # resources and services will be prepared to execution.
      # return (bool) true if all of the components are read.
      def prepare
        @tests = Array.new

        items = %w(PUSHPOP PUSHPOPSIZE NEWSTACKINDEX NEWSTACKSIZE)
        items.each do |item|
          if @options["#{item}_RATIO"].to_i >= 1
            1.upto(@options["#{item}_RATIO"].to_i) do
              @tests.push item
            end
          end
        end

        #This will add other tests as well based on ratios listed in ADSSTACK
        super
      end

      def domain
        return 'ALGEBRAICADS-STACK'
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
        unless is_procedure?( procedure )
          procedure = build_skeleton( test )
        end


        case test.downcase
          when 'pushpop'
            return manage_pushpop( procedure )
          when 'pushpopsize'
            return manage_pushpopsize( procedure )
          when 'newstackindex'
            return manage_newstackindex( procedure )
          when 'newstacksize'
            return manage_newstacksize( procedure )
          else
            #Call super here
            return super(test, procedure)
        end

        return procedure
      end

      def build_pushpop_new( next_step )
        procedure = build_skeleton( 'PUSHPOP' )
        procedure.add_step( build_push_new(next_step).steps[0] )
        procedure.add_step( build_pop_new(next_step).steps[0] )
        procedure.add_step( build_details_new(next_step).steps[0])

        procedure.id = next_step
        return procedure
      end

      def build_pushpop_finalize( procedure, steps )
        unless is_procedure?( procedure ) and is_step?( steps[0] ) and is_step?( steps[1] ) and is_step? (steps[2])
          return procedure
        end

        steps[0].id = 'PUSH'
        steps[1].id = 'POP'
        steps[2].id = 'DETAILS'
        procedure.id = 'PUSHPOP'

        rvalue = steps[0].get_parameter_value( '[RVALUE]' )
        if rvalue != ''
          procedure.done
        else
          procedure.failed
        end

        return procedure
      end

      #build a Stack Push Pop procedure
      def manage_pushpop (procedure)

        unless is_procedure?( procedure )
          return procedure
        end

        case procedure.id
          when 'PUSHPOP-NEW'
            return build_pushpop_new('PUSHPOP-LAST')
          when 'PUSHPOP-LAST'
            return build_pushpop_finalize( procedure, procedure.steps )
          else
        end

        return procedure


      end



      #build a Stack Push Pop Size procedure
      def manage_pushpopsize (procedure)

        unless is_procedure?( procedure )
          return procedure
        end

        case procedure.id
          when 'PUSHPOPSIZE-NEW'
            return build_pushpopsize_new('PUSHPOPSIZE-LAST')
          when 'PUSHPOPSIZE-LAST'
            return build_pushpopsize_finalize( procedure, procedure.steps )
          else
        end

        return procedure


      end

      def build_pushpopsize_new( next_step )
        procedure = build_skeleton( 'PUSHPOPSIZE' )
        procedure.add_step( build_push_new(next_step).steps[0] )
        procedure.add_step( build_pop_new(next_step).steps[0] )
        procedure.add_step( build_size_new(next_step).steps[0] )

        procedure.id = next_step
        return procedure
      end

      def build_pushpopsize_finalize( procedure, steps )
        unless is_procedure?( procedure ) and is_step?( steps[0] ) and is_step?( steps[1] ) and is_step?( steps[2] )
          return procedure
        end

        steps[0].id = 'PUSH'
        steps[1].id = 'POP'
        steps[2].id = 'SIZE'
        procedure.id = 'PUSHPOPSIZE'

        rvalue = steps[0].get_parameter_value( '[RVALUE]' )
        if rvalue != ''
          procedure.done
        else
          procedure.failed
        end

        return procedure
      end

      #build a new stack index procedure
      def manage_newstackindex (procedure)

        unless is_procedure?( procedure )
          return procedure
        end

        case procedure.id
          when 'NEWSTACKINDEX-NEW'
            return build_newstackindex_new('NEWSTACKINDEX-LAST')
          when 'NEWSTACKINDEX-LAST'
            return build_newstackindex_finalize( procedure, procedure.steps )
          else
        end

        return procedure


      end

      def build_newstackindex_new( next_step )
        procedure = build_skeleton( 'NEWSTACKINDEX' )
        procedure.add_step( build_create_new(next_step).steps[0] )
        procedure.add_step( build_at_index_new(next_step).steps[0] )

        procedure.id = next_step
        return procedure
      end

      def build_newstackindex_finalize( procedure, steps )
        unless is_procedure?( procedure ) and is_step?( steps[0] ) and is_step?( steps[1] )
          return procedure
        end

        steps[0].id = 'NULCONSTRUCT'
        steps[1].id = 'ATINDEX'

        procedure.id = 'NEWSTACKINDEX'

        rvalue = steps[1].get_parameter_value( '[INDEX]' )
        if rvalue != ''
          procedure.done
          @has_stack = true
          @stack_size = 0
        else
          procedure.failed
        end

        return procedure
      end

      #build a new stack size procedure
      def manage_newstacksize (procedure)

        unless is_procedure?( procedure )
          return procedure
        end

        case procedure.id
          when 'NEWSTACKSIZE-NEW'
            return build_newstacksize_new('NEWSTACKSIZE-LAST')
          when 'NEWSTACKSIZE-LAST'
            return build_newstacksize_finalize( procedure, procedure.steps )
          else
        end

        return procedure


      end

      def build_newstacksize_new( next_step )
        procedure = build_skeleton( 'NEWSTACKSIZE' )
        procedure.add_step( build_create_new(next_step).steps[0] )
        procedure.add_step( build_size_new(next_step).steps[0] )

        procedure.id = next_step
        return procedure
      end

      def build_newstacksize_finalize( procedure, steps )
        unless is_procedure?( procedure ) and is_step?( steps[0] ) and is_step?( steps[1] )
          return procedure
        end

        steps[0].id = 'NULCONSTRUCT'
        steps[1].id = 'SIZE'

        procedure.id = 'NEWSTACKSIZE'
        @has_stack = true
        @stack_size = 0
        procedure.done

        return procedure
      end

    end
  end
end