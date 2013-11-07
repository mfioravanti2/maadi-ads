# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : LocalWindowsProcessModules.rb
#
# Summary: This is a Local Windows Process Modules Monitor

require_relative 'factory'
require_relative '../../core/helpers'

class Array
  def integer_sum
    sum = 0
    self.map{|x| sum += x.to_i}
    return sum
  end
end

module Maadi
  module Monitor
    class LocalWindowsProcessModules < Monitor

      def initialize
        super('LocalWindowsSystemMemory')
      end

      def is_ok?
        return true
      end
      def prepare
        begin

        rescue => e
          Maadi::post_message(:Warn, "Monitor (#{@type}:#{@instance_name}) was unable to initialize (#{e.message}).")
        end

        super
      end

      def supports_step?( step )
        if Maadi::Procedure::Step.is_step?( step )
          return %w( ).include?( step.id )
        end

        return false
      end

      def execute( test_id, procedure )
        results = Maadi::Procedure::Results.new( test_id.to_i, 0, "#{@type}:#{@instance_name}", nil )

        if procedure.is_a?( ::Maadi::Procedure::Procedure )
          results.proc_id = procedure.id

          procedure.steps.each do |step|
            if step.target == execution_target
              if supports_step?( step )

                begin
                  case step.look_for
                    when 'NORECORD'
                    else
                      results.add_result( Maadi::Procedure::Result.new( step, step.look_for, 'TEXT', 'UNKNOWN' ))
                  end
                rescue => e
                  Maadi::post_message(:Warn, "Monitor (#{@type}:#{@instance_name}) encountered an error (#{e.message}).")
                  results.add_result( Maadi::Procedure::Result.new( step, e.message, 'TEXT', 'EXCEPTION' ))
                end
              else
                Maadi::post_message(:Warn, "Monitor (#{@type}:#{@instance_name}) encountered an unsupported step (#{procedure.id}, #{step.id}).")
              end
            end
          end
        end

        return results
      end

      def teardown
        super
      end

    end
  end
end