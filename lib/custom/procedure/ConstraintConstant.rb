# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : ConstraintSingleString.rb
# License: Creative Commons Attribution
#
# Summary: Implementation of a Constraint which will always return a constant.

require_relative '../../core/procedure/constraint'

module Maadi
  module Procedure
    class ConstraintConstant < Constraint
      attr_accessor :value

      def initialize( value )
        super('CONSTANT')
        @value = value
      end

      # obtain a detailed printable version of the constraint
      # return (String) detailed string representing the constraint
      def display
        return "#{@type} (#{@value})"
      end

      # attempt to automatically generate a value that would
      # satisfy the constraint
      # return (any) a value that would satisfy the constraint
      def satisfy
         return @value
      end

      # determine if a specific value satisfies the constraint
      # value (any) value to be tested
      # returns (bool) true, if the constraint is satisfied
      def satisfies?( value )
        if value != nil
          if value.is_a?( String )
            return ( @value == value )
          elsif value.is_a?( Fixnum ) or value.is_a?( Bignum )
            return ( @value == value )
          end
        end

        return false
      end
    end
  end
end