
require_relative 'factory'
require_relative '../../core/helpers'


module Maadi
  module Expert
    class ADSStack < Expert

      def initialize
        super('ADSStack')

        @tests = Array.new
        @stack_size = 0

        @options['CREATE_RATIO'] = 1
        @options['PUSH_RATIO'] = 1
        @options['POP_RATIO'] = 1
        @options['ATINDEX_RATIO'] = 1
        @options['SIZE_RATIO'] = 1

        @notes['CREATE_RATIO'] = 'Relative Ratio for CREATE commands (0 or less, ignore command type)'
        @notes['PUSH_RATIO'] = 'Relative Ratio for PUSH commands (0 or less, ignore command type)'
        @notes['POP_RATIO'] = 'Relative Ratio for POP commands (0 or less, ignore command type)'
        @notes['ATINDEX_RATIO'] = 'Relative Ratio for AT INDEX commands (0 or less, ignore command type)'
        @notes['SIZE_RATIO'] = 'Relative Ratio for SIZE commands (0 or less, ignore command type)'
      end

      # returns (String) which the the domain that this expert specializes in
      def domain
        return 'ADS-STACK'
      end

      # prepare will setup the execution environment.  No tests will be executed but all required
      # resources and services will be prepared to execution.
      # return (bool) true if all of the components are read.
      def prepare
        @tests = Array.new

        items = %w(CREATE PUSH POP ATINDEX SIZE)
        items.each do |item|
          if @options["#{item}_RATIO"].to_i >= 1
            1.upto(@options["#{item}_RATIO"].to_i) do
              @tests.push item
            end
          end
        end

        super
      end

      # returns (Array of Strings) which lists all of the tests that the
      # expert currently supports, as various procedures are generated, different
      # tests become available or are not longer available.  The Stack expert is
      # partially stateful wrt constructing databases and tables.
      def tests
        if @stack_szie.length < 1
          return %w(CREATE)
        end

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
        unless is_procedure?( procedure )
          procedure = build_skeleton( test )
        end

        case test.downcase
          when 'create'
            return manage_create( procedure )
          when 'push'
            return manage_push( procedure )
          when 'pop'
            return manage_pop( procedure )
          when 'atindex'
            return manage_atindex( procedure )
          when 'size'
            return manage_size( procedure )
          else
        end

        return procedure
      end

      def build_skeleton( test )
        procedure = Maadi::Procedure::Procedure.new( test + '-NEW')
        return procedure
      end

      # build a STACK CONSTRUCTOR procedure
      # this will allow the construction of a new STACK with either NULL or NON-NULL CONSTRUCTORS
      def manage_create( procedure )
        unless is_procedure?( procedure )
          return procedure
        end

        case procedure.id
          when 'CREATE-NEW'
            procedure = build_create_new( 'CREATE-NEW-NEXT' )
            return build_add_create_type( procedure, procedure.steps[0], 'CREATE-NEW-NEXT' )
          when 'CREATE-NEW-NEXT'
            case procedure.steps[0].get_parameter_value( '[CREATE-TYPE]' )
              when 'NULL'
                return build_add_redirect( procedure, procedure.steps[0], 'CREATE-NULL-NEW' )
              when 'NOTNULL'
                return build_add_redirect( procedure, procedure.steps[0], 'CREATE-NOTNULL-NEW' )
              else
                return procedure
            end
          when 'CREATE-NULL-NEW'
            return build_add_create_database_name( procedure, procedure.steps[0], 'CREATE-NULL-LAST' )
          when 'CREATE-NULL-LAST'
            return build_create_database_finalize( procedure, procedure.steps[0] )
          when 'CREATE-NOTNULL-NEW'
            return build_add_create_table_name( procedure, procedure.steps[0], 'CREATE-NOTNULL-PARAMS' )
          when 'CREATE-NOTNULL-PARAMS'
            return build_add_create_table_columns( procedure, procedure.steps[0], 'CREATE-NOTNULL-LAST' )
          when 'CREATE-NOTNULL-LAST'
            return build_create_table_finalize( procedure, procedure.steps[0] )
          else
        end

        return procedure
      end

      def build_step( test, look_for, command, on_failure )
        parameters = Array.new
        step = Maadi::Procedure::Step.new(test + '-WIP', 'application', look_for, command, parameters, on_failure)
        return step
      end

      def build_add_redirect( procedure, step, next_step, failed = false )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        procedure.id = next_step

        if failed
          procedure.failed
        end

        return procedure
      end

      def build_create_new( next_step )
        procedure = build_skeleton( 'CREATE' )
        step = build_step('CREATE', 'COMPLETED', '', 'TERM-PROC' )

        procedure.add_step( step )
        procedure.id = next_step

        return procedure
      end

      def build_add_create_type( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        constraint = Maadi::Procedure::ConstraintPickList.new( %w(NULL NOTNULL) )
        step.parameters.push Maadi::Procedure::Parameter.new('[CREATE-TYPE]', constraint )

        procedure.id = next_step
        return procedure
      end

      # build a STACK PUSH procedure
      # this will allow a value to be pushed onto a stack.
      def manage_push( procedure )
        unless is_procedure?( procedure )
          return procedure
        end

        case procedure.id
          when ''
          else
        end

        return procedure
      end

      # build a STACK POP procedure
      # this will allow a value to be popped from a stack.
      def manage_pop( procedure )
        unless is_procedure?( procedure )
          return procedure
        end

        case procedure.id
          when ''
          else
        end

        return procedure
      end

      # build a STACK AT INDEX procedure
      # this will allow a value to be pushed onto a stack.
      def manage_atindex( procedure )
        unless is_procedure?( procedure )
          return procedure
        end

        case procedure.id
          when ''
          else
        end

        return procedure
      end

      # build a STACK SIZE procedure
      # this will allow a value to be popped from a stack.
      def manage_size( procedure )
        unless is_procedure?( procedure )
          return procedure
        end

        case procedure.id
          when ''
          else
        end

        return procedure
      end


    end
  end
end