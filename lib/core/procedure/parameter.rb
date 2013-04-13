# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : parameter.rb
# License: Creative Commons Attribution
#
# Summary: A parameter represents a single component of a command that
#          is variable.  The variable component is selected for the test
#          by an implemented constraint or the test organizer.

require_relative 'constraint'

module Maadi
  module Procedure
    class Parameter
      attr_accessor :label, :constraint, :value, :values, :quotes, :key_id

      def initialize(label, constraint, quotes = '')
        @label = label
        @constraint = constraint
        @quotes = quotes

        @key_id = -1

        reset_values
      end

      def to_s
        return @label
      end

      def reset_values
        @value = ''
        @values = Array.new
      end

      def populate_value
        value = @constraint.satisfy

        if value.is_a?( Array )
          @value = ''
          @values = value
        else
          @value = @quotes.to_s + value.to_s + @quotes.to_s
          @values = Array.new
        end
      end
    end
  end
end