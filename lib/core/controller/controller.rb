# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : controller.rb
# License: Creative Commons Attribution
#
# Summary: The Controller class uses a generator to build test procedures and pass them along
#          along to the individual applications under test.  The results are stored in the
#          data store for later analysis.

require_relative '../generic/generic'
require_relative '../generator/generator'
require_relative '../helpers'

module Maadi
  module Controller
    class Controller < Maadi::Generic::Generic

      # limited attributes are available for use.
      # runs (integer) is the number of test cases that will be executed
      attr_accessor :runs

      # generator (class Generator) is an object that will build test procedures
      # applications is an array of applications (class Application) that the test procedures will be executed against
      # collector (class Collector) is an object that will record the results of the execution of the test procedures
      # runs (Integer) is the number of runs that will be executed.
      def initialize( scheduler, generator, applications, collectors, runs )
        super('Controller')
        @instance_name = 'Controller'

        @scheduler = scheduler
        @generator = generator
        @applications = applications
        @collectors = collectors
        @runs = runs

        @prng = nil
        @options['RANDSEED'] =  Random.new_seed
        @options['MAXFAILS'] =  10
        @options['SHOWFAILS'] = 'false'

        @notes['RANDSEED'] = 'Seed Value for the PRNG'
        @notes['MAXFAILS'] = 'Maximum number of Procedure Generation failure before aborting.'
        @notes['SHOWFAILS'] = 'Display details of a Procedure that has failed (true/false).'
      end

      # prepare will setup the execution environment.  No tests will be executed but all required
      # resources and services will be prepared to execution.
      # return (bool) true if all of the components are read.
      def prepare
        @ready = false

        if ( @applications != nil ) && ( @collectors != nil )
          if @scheduler.is_a?(Maadi::Scheduler::Scheduler) && @generator.is_a?( Maadi::Generator::Generator) && @applications.is_a?(Array) && @collectors.is_a?(Array)
            if ( @applications.length > 0 ) && ( @collectors.length > 0 )

              Maadi::post_message(:Info, "Controller is setting the PRNG seed (#{@options['RANDSEED']})")
              srand( @options['RANDSEED'] )

              # manager prepares the collectors, so the controller should not worry about it.
              unless @generator.prepare_for_tests( @runs, @collectors )
                return @ready
              end

              @applications.each do |application|
                if application.works_with?( @generator.using_domain )
                  Maadi::post_message(:Info, "Expert (#{@generator.using_domain}) and Application (#{application.type}) are compatible")
                else
                  Maadi::post_message(:Warn, "Expert (#{@generator.using_domain}) is NOT compatible with Application (#{application.type}) (#{application.supported_domains.join(', ')})")
                  return @ready
                end

                unless application.is_ready?
                  application.prepare

                  unless application.is_ready?
                    return @ready
                  end

                  @collectors.each do |collector|
                    collector.log_options( application )
                  end
                end
              end

              Maadi::post_message(:Info, 'Controller is collecting procedures from Generator')
              failures = 0
              while @scheduler.procedure_count < @runs
                procedure = @generator.next_test
                if procedure != nil
                  if procedure.has_failed?
                    failures += 1

                    if @options['SHOWFAILS'].downcase == 'true'
                      puts "FAILED: #{procedure.id}"
                    end
                  else
                    @scheduler.add_procedure( procedure )
                  end
                else
                  failures += 1
                end

                if @options['MAXFAILS'].to_i <= failures
                  @ready = false
                  Maadi::post_message(:Info, "Controller exceeded maximum number of procedure failures (Encountered: #{failures.to_s}, Maximum: #{@options['MAXFAILS'].to_s} )")
                  return @ready
                end
              end
              Maadi::post_message(:Info, 'Controller has completed collecting procedures from Generator')

              unless @scheduler.is_ready?
                @scheduler.prepare

                unless @scheduler.is_ready?
                  return @ready
                end

                @collectors.each do |collector|
                  collector.log_options( @scheduler )
                end
              end
              Maadi::post_message(:Info, "Scheduler (#{@scheduler.type}) is logging the schedule")
              @scheduler.log( @collectors )
              Maadi::post_message(:Info, "Scheduler (#{@scheduler.type}) has completed logging the schedule")

              @collectors.each do |collector|
                collector.log_options( self )
              end

              Maadi::post_message(:More, 'Controller is ready')
              @ready = true
            else
              Maadi::post_message(:Warn, "Only #{@applications.length} Applications and #{@collectors.length} Collectors available.  Need at least 1 (of each).")
            end
          else
            Maadi::post_message(:Warn, 'Applications, Collectors, Generator or Scheduler is NOT of correct type')
          end
        else
          Maadi::post_message(:Warn, 'Applications, Collectors, Generator or Scheduler is NOT initialized')
        end

        return @ready
      end

      # start will begin collecting the test procedures, passing the test procedures to the applications interfaces for
      # execution, and collect the results.
      def start
        if @scheduler != nil
          # The schedule has already been logged by the prepare function
          #Maadi::post_message(:Info, 'Controller is logging Schedule')
          #@scheduler.log( @collectors )

          Maadi::post_message(:Info, 'Controller is EXECUTING Schedule')
          is_ok = @scheduler.execute( @applications, @collectors )
          Maadi::post_message(:Info, "Schedule execution #{ is_ok ? 'completed successfully' : 'failed'}")
        end
      end

      # teardown will remove all of the resources and services that were created specifically for this test.
      def teardown
        @scheduler.teardown
        @generator.teardown

        @applications.each { |application| application.teardown }

        # do NOT teardown the collectors!   This will be done by another subsystem!
        # @collectors.teardown
        Maadi::post_message(:Less, 'Controller is NO longer ready')
        super
      end

      def self.is_controller?( controller )
        if controller != nil
          if controller.is_a?( Maadi::Controller::Controller )
            return true
          end
        end

        return false
      end
    end
  end
end
