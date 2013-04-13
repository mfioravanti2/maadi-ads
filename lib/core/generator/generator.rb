# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : generator.rb
# License: Creative Commons Attribution
#
# Summary: The generator utilizes a domain expert (Expert) and a test case
#          organizer (Organizer) to assemble a suite of tests to be executed
#          against an application.

require_relative '../generic/generic'
require_relative '../expert/expert'
require_relative '../organizer/organizer'
require_relative '../helpers'

module Maadi
  module Generator
    class Generator < Maadi::Generic::Generic

      # expert (Expert) is an object that represents the domain expertise for the tests
      # organizer (Organizer) is an object that will determine how the test parameters are selected
      def initialize( expert, organizer )
        super('Generator')
        @instance_name = 'Generator'

        @expert = expert
        @organizer = organizer

        @options['MAX-STEPS'] =  25

        @notes['MAX-STEPS'] = 'Maximum number of cycles to allow the Generator and Expert interact per procedure'
      end

      def using_domain
        if @expert != nil
          if @expert.is_a?( Maadi::Expert::Expert )
            return @expert.domain
          end
        end

        return ''
      end

      # prepare the organizer for the tests.
      # runs (Integer) is the number of runs that will be executed.
      # return (bool) true if all of the components are read.
      def prepare_for_tests( runs )
        if @expert != nil && @organizer != nil
          if @expert.is_a?( Maadi::Expert::Expert ) && @organizer.is_a?( Maadi::Organizer::Organizer )
            if @organizer.works_with?( @expert.domain )
              Maadi::post_message(:Info, 'Expert and Organizer are compatible')
            else
              Maadi::post_message(:Warn, "Expert (#{@expert.domain}) is NOT compatible with Organizer (#{@organizer.supported_domains.join(', ')})")
              return false
            end

            if !@expert.is_ready?
              @expert.prepare
            end

            if !@organizer.is_ready?
              @organizer.prepare
            end

            if @expert.is_ready? && @organizer.is_ready?
              parameters = @expert.parameters( 'all' )
              ready = @organizer.available_parameters( parameters, runs )

              if ready
                Maadi::post_message(:More, 'Generator is ready')
                return true
              end
            else
              Maadi::post_message(:Warn, 'Expert or Organizer NOT ready')
            end
          else
            Maadi::post_message(:Warn, 'Expert or Organizer NOT of correct type')
          end
        else
          Maadi::post_message(:Warn, 'Expert or Organizer NOT initialized')
        end

        return false
      end

      # select and generate the next test case
      # return (Procedure) a completed test procedure
      def next_test
        tests = @expert.tests
        item = @organizer.select_test( tests )
        procedure = @expert.procedure( item, nil )

        count = 1
        while !procedure.is_complete?
          #puts "GENERATOR: #{procedure.id}"
          @organizer.populate_parameters!( procedure )
          procedure = @expert.procedure( item, procedure )

          if procedure.has_failed?
            #puts 'Procedure FAILED!!! (Unknown Organizer/Expert failure)'
            #@expert.show
            #puts "id: #{procedure.id}, steps: #{procedure.steps.length}"
            #procedure.steps.each do |step|
            #  puts "step: #{step.command} (#{step.parameters.length} available parameters)"
            #  step.parameters.each do |parameter|
            #    puts "* parameter: #{parameter.label} =  #{parameter.value}"
            #  end
            #end
            break
          end

          count += 1
          if @options['MAX-STEPS'].to_i < count
            procedure.failed
            #puts 'Procedure FAILED!!! (Max Steps Exceeded)'
            break
          end
        end

        return procedure
      end

      # teardown the object if any database connections, files, etc. are open.
      def teardown
        @expert.teardown
        @organizer.teardown
        Maadi::post_message(:Less, 'Generator is NO longer ready')
      end
    end
  end
end