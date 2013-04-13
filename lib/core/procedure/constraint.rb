# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : constraint.rb
# License: Creative Commons Attribution
#
# Summary: Constraints serve as objects to limit and generate values
#          within a set of constraints.  For example a constraint
#          could be generate a random integer between 5 and 12.

require_relative 'result'

module Maadi
  module Procedure
    class Constraint
      attr_accessor :type

      def initialize(type)
        @type = type
      end

      # convert the constraint to a printable string
      # return (String) string representing a printable (e.g. descriptive) version of the constraint
      def to_s
        return @type
      end

      # obtain a detailed printable version of the constraint
      # return (String) detailed string representing the constraint
      def display
        return to_s
      end

      # attempt to automatically generate a value that would
      # satisfy the constraint
      # return (any) a value that would satisfy the constraint
      def satisfy
        return ''
      end

      # determine if a specific value satisfies the constraint
      # value (any) value to be tested
      # returns (bool) true, if the constraint is satisfied
      def satisfies?( value )
        return false
      end
    end
  end
end