# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : Example.rb
#
# Summary: This is an Example (i.e. Toy) Application which can be
#          used for testing or as a template

require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Application
    class Example < Application

      def initialize
        super('Example')
      end

      def supported_domains
        return %w(SQL Spreadsheet Document)
      end

      def prepare
        begin

        rescue => e
          Maadi::post_message(:Warn, "Application (#{@type}:#{@instance_name}) was unable to initialize (#{e.message}).")
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
                  Maadi::post_message(:Warn, "Application (#{@type}:#{@instance_name}) encountered an error (#{e.message}).")
                  results.add_result( Maadi::Procedure::Result.new( step, e.message, 'TEXT', 'EXCEPTION' ))
                end
              else
                Maadi::post_message(:Warn, "Application (#{@type}:#{@instance_name}) encountered an unsupported step (#{procedure.id}, #{step.id}).")
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