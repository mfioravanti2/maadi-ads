# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : ConstraintSingleWord.rb
#
# Summary: Implementation of a Constraint which will produce a single
#          string of random characters.

require_relative '../../core/procedure/constraint'

module Maadi
  module Procedure
    class ConstraintSingleWord < Constraint
      attr_accessor :min_length, :max_length

      def initialize( min_length, max_length )
        super('ALPHANUMERIC WORD')
        @min_length = [ 0, min_length.to_i ].max
        @max_length = [ min_length.to_i, max_length.to_i ].max
      end

      # obtain a detailed printable version of the constraint
      # return (String) detailed string representing the constraint
      def display
        return "#{@type} (LENGTH MIN: #{@min_length}, MAX: #{@max_length})"
      end

      # attempt to automatically generate a value that would
      # satisfy the constraint
      # return (String) a value that would satisfy the constraint
      def satisfy
        # generate a length between our min,max

        # ensure the first character is a alphabetic character (non-numeric)
        list = [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
        value = list.sample

        # generate a random length between our min, max - 1, since we
        # already selected our first character as non-numeric
        # randomly pick characters from the list and append to the string
        length = @min_length + rand( @max_length - @min_length ).to_i - 1
        list = [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten
        if length > 0
          length.times { value << list.sample }
        end

        return value
      end

      # determine if a specific value satisfies the constraint
      # value (any) value to be tested
      # returns (bool) true, if the constraint is satisfied
      def satisfies?( value )
        if value != nil
          if value.is_a?( String )
            if ( min_length <= value.length ) && ( value.length <= max_length )
              return ( value =~ /[a-zA-Z][a-zA-Z0-9]+/ ) != nil
            end
          end
        end

        return false
      end
    end
  end
end