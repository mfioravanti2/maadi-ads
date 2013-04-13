# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : ConstraintRangedInteger.rb
# License: Creative Commons Attribution
#
# Summary: Implementation of a Constraint which will produce a random
#          integer within a specified range.

require_relative '../../core/procedure/constraint'

module Maadi
  module Procedure
    class ConstraintRangedInteger < Constraint
      attr_accessor :min_value, :max_value

      def initialize( min_value, max_value )
        super('RANGED-INTEGER')
        @min_value = [ 0, min_value.to_i ].max
        @max_value = [ min_value.to_i, max_value.to_i ].max
      end

      # obtain a detailed printable version of the constraint
      # return (String) detailed string representing the constraint
      def display
        return "#{@type} (MIN: #{@min_value}, MAX: #{@max_value})"
      end

      # attempt to automatically generate a value that would
      # satisfy the constraint
      # return (Integer) a value that would satisfy the constraint
      def satisfy
        # generate a length between our min,max
        return @min_value + rand( @max_value - @min_value ).to_i
      end

      # determine if a specific value satisfies the constraint
      # value (any) value to be tested
      # returns (bool) true, if the constraint is satisfied
      def satisfies?( value )
        if value != nil
          if value.is_a?( Fixnum ) or value.is_a?( Bignum )
            return ( ( min_value <= value.to_i ) && ( value.to_i <= max_value ) )
          end
        end

        return false
      end
    end
  end
end