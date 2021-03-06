# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : procedure.rb
#
# Summary: Test Procedure contains all of the steps that should be
#          executed against an application under test.  It also contains
#          the specific items which should be monitored and returned as
#          Test Results.

require_relative 'comparison'
require_relative 'step'

module Maadi
  module Procedure
    class Procedure
      # limited attributes are available for use.
      # id (String) is a convenient human readable label.
      # key_id (Integer) unique ID to represent the test case.
      #                  if this is logged into a database, it should be the row ID
      #                  otherwise it should just be the test case execution number
      # steps (Array of Step) is an array of Step objects, which denotes each individual step of the procedure.
      # parameters (Array of Parameter) is an array of Parameters which are used in the individual steps
      # parameters (Array of Comparison) is an array of Comparisons which are used in to compare the
      attr_accessor :id, :key_id, :steps, :parameters, :comparisons

      def initialize(id)
        @id = id
        @key_id = -1
        @parameters = Array.new
        @comparisons = Array.new
        @steps = Array.new
        @complete = false
        @is_bad = false
      end

      def add_step( step )
        if step.is_a?( Step )
          @steps.push step
          @parameters.push step.parameters
        end
      end

      def get_label( label )
        @steps.each do |step|
          if step.id == label
            return step
          end
        end

        return nil
      end

      def to_s
        return @id.to_s
      end

      def done
        @complete = true
      end

      def failed
        @is_bad = true
      end

      def not_failed
        @is_bad = false
      end

      def has_failed?
        return @is_bad
      end

      def is_complete?
        return @complete
      end

      def get_step_keys
        keys = Array.new
        @steps.each { |step| keys.push step.id }
        return keys
      end

      def has_step?( id )
        return ( get_step( id ) != nil )
      end

      def get_step( id )
        @steps.each do |step|
          if step.id == id
            return step
          end
        end

        return nil
      end

      def get_comparison( comparison )
        @comparisons.each do |item|
          if item.id == comparison
            return item
          end
        end

        return nil
      end

      def show
        puts "\nPROCEDURE: #{@id} (Status: #{ ( is_complete? ) ? 'DONE' : 'WIP'}, #{ ( has_failed? ) ? 'FAILED' : 'SUCCESS'})."

        @steps.each do |step|
          puts "\tSTEP: #{step.id} (Looking for #{step.look_for})"
          step.parameters.each do |parameter|
            puts "\t\tPARAMETER: #{parameter.label} = #{parameter.value}"
            if parameter.constraint != nil
              puts "\t\t\tCONSTRAINT: #{parameter.constraint.display}"
            end
          end
        end

        @comparisons.each do |comparison|
          puts "\tCOMPARE: #{comparison.id} with #{comparison.relationship}"
          comparison.steps.each do |item|
            puts "\t\tSTEP: #{item.id}"
          end
        end
      end

      def self.is_procedure?( procedure, with_id = '' )
        if procedure != nil
          if procedure.is_a?( Maadi::Procedure::Procedure )
            if with_id != ''
              if procedure.id == with_id
                return true
              end
            else
              return true
            end
          end
        end

        return false
      end
    end
  end
end