# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : step.rb
#
# Summary: Test Procedure contains all of the steps that should be
#          executed against an application under test.  It also contains
#          the specific items which should be monitored and returned as
#          Test Results.

require_relative 'parameter'

module Maadi
  module Procedure
    class Step
      # id (String) is the name of the Test Procedure that these results are associated with
      # target (String) is the type of object that this procedure executes against
      # look_for (String) is what to look for (COMPLETE, NORECORD, etc.), the target needs to now how to
      #      NORECORD     should be used for instances where you are not interested in capturing the
      #                   results of the execution against the application.
      #      COMPLETE     should be used for instances where you are just interested in capturing that
      #                   the step was completed without an exception.
      #      EXCEPTION    should be used for instances where an exception was encountered while attempting
      #                   to execute the step.
      #      <As Needed>  others will be defined as necessary by the Domain Expert.  Applications, Monitors
      #                   and Taskers should know how to handle recording any values in the look_for, default
      #                   behavior (i.e. or in the case of unknown commands), a new result should be generated
      #                   and it should have no data and list its status as 'UNKNOWN'
      # command (String) is the command that is to be executed, the target should know how to execute the command
      # parameters (Array of Strings) any configurable parameters for the command string should be included
      # on_fail (String)  is what to do if a problem is encountered, the application should be told what to do
      #                   if the procedure fails.
      #      CONTINUE     should be used when the program should continue on to the next step
      #      TERM-TEST    should be used when the program should terminate testing
      #      TERM-PROC    should be used when the program should terminate any further tests with the procedure,
      #                   e.g. any of the following test steps will not be executed.
      # key_id (Integer) unique ID to represent the step of the test case.
      #                  if this is logged into a database, it should be the row ID
      #                  otherwise it should just be the test case execution number
      attr_accessor :id, :target, :look_for, :command, :parameters, :on_fail, :key_id

      def initialize( id, target, look_for, command, parameters, on_fail )
        @id = id
        @target = target
        @look_for = look_for
        @command = command
        @parameters = parameters
        @on_fail = on_fail
        @key_id = -1
      end

      def execute( max_loops = 25 )
        start_cmd = String.new( @command.to_s )
        final_cmd = String.new( @command.to_s )

        # some parameters may reference other parameters,
        # so multiple substitution passes may be needed
        # execute the loop until there are not more changes!
        i = 0
        while i < max_loops
          parameters.each do |parameter|
            start_cmd.gsub!( parameter.label, parameter.value.to_s )
            #if parameter.value != ''
            #  final_cmd.gsub!( parameter.label, parameter.value.to_s )
            #end
          end

          break if start_cmd == final_cmd
          final_cmd = String.new( start_cmd )
          i += 1
        end

        return final_cmd
      end

      def get_parameter_keys
        keys = Array.new
        @parameters.each { |parameter| keys.push parameter.label }
        return keys
      end

      def has_parameter?( label )
        return ( get_parameter( label ) != nil )
      end

      def get_parameter( label )
        @parameters.each do |parameter|
          if parameter.label == label
            return parameter
          end
        end

        return nil
      end

      def get_parameter_value( label )
        parameter = get_parameter( label )

        if parameter
          return parameter.value
        end

        #@parameters.each do |parameter|
        #  if parameter.label == label
        #    return parameter.value
        #  end
        #end

        return ''
      end

      def set_parameter_value( label, value )
        @parameters.each do |parameter|
          if parameter.label == label
            parameter.value = value
            break
          end
        end
      end

      def self.is_step?( step )
        if step != nil
          if step.is_a?( Maadi::Procedure::Step )
            return true
          end
        end

        return false
      end
    end
  end
end