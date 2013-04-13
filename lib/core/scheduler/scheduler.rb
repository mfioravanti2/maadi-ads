# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : controller.rb
# License: Creative Commons Attribution
#
# Summary: The scheduler will take a collection of test procedures and assemble them
#          in an order to be executed against the applications.  It should record the
#          execution schedule before executing the procedures.

require_relative '../generic/generic'
require_relative '../procedure/procedure'
require_relative '../procedure/result'
require_relative '../helpers'

module Maadi
  module Scheduler
    class Scheduler < Maadi::Generic::Generic
      # type (String) is a convenient human readable label.
      def initialize(type)
        super(type)
        @procedures = Array.new
        @ready = false
        @logged = false
        @done = false
        @name = ''
      end

      # add a *completed* test procedure to the scheduler
      # procedure (Procedure) procedure which is to be added to the scheduler
      # return N/A
      def add_procedure( procedure )
        if procedure != nil
          @procedures.push( procedure )
          @ready = false
        end
      end

      def procedure_count
        return @procedures.length
      end

      # assemble the schedule (the default schedule is FIFO based the added procedures)
      # this should be overloaded for inherited classes to generated the desired order.
      # return (bool) return true if the scheduler is ready and the schedule has been built
      def prepare
        @name = 'Schedule ID'
        @ready = true

        Maadi::post_message(:More, "Scheduler (#{@type}) is ready")
        super
      end

      # log the assembled schedule in the Collector
      # collector (Collector) database to store the finalized schedule
      # return N/A
      def log( collectors )
        if collectors != nil
          collectors.each do |collector|
            @procedures.each { | procedure | collector.log_procedure( procedure ) }
          end

          @logged = true
        end
      end

      # query the scheduler to determine if the schedule has been logged
      # return (bool) true if the scheduler has successfully logged the entire schedule to a collector
      def is_logged?
        return @logged
      end

      def is_done?
        return @done
      end

      # query the scheduler to determine the build schedule name
      # return (String) the name of the schedule
      def name
        return @name
      end

      # execute the schedule procedures against all of the applications, and record the
      # results in the specified collector
      # applications (Array of Applications) all of the applications to execute the procedures against
      # collector (Collector) database which stored the results of the schedule or procedures
      def execute( applications, collectors )
        if ( applications.is_a?( Array ) ) && ( collectors.is_a?( Array ) ) && ( @procedures.length > 0 )
          Maadi::post_message(:Info, 'Scheduler started')

          run = 1
          @procedures.each do | procedure |

            Maadi::post_message(:Info, "Executing Procedure #{procedure.to_s}")
            applications.each do | application |
              collectors.each do |collector|
                collector.log_message( :Info, "Executing Procedure #{procedure.to_s}" )
              end

              if application.supports_procedure?( procedure )
                results = application.execute( run, procedure )

                collectors.each do |collector|
                  collector.log_results( application, procedure, results )
                end
              else
                msg = "Application (#{application.type}:#{application.instance_name}) encountered an unsupported procedure (#{procedure.id})."

                Maadi::post_message(:Warn, msg)
                collectors.each do |collector|
                  collector.log_message( :Warn, msg )
                end
              end
            end

            run += 1
          end
          Maadi::post_message(:Info, 'Scheduler completed')
        end

        @schedule_done = true
        return @schedule_done
      end

      # teardown will remove all of the resources and services that were created specifically for this test.
      def teardown
        Maadi::post_message(:Less, "Scheduler (#{@type}) is NO longer ready")
        super
      end

      def self.is_scheduler?( scheduler )
        if scheduler != nil
          if scheduler.is_a?( Maadi::Scheduler::Scheduler )
            return true
          end
        end

        return false
      end
    end
  end
end