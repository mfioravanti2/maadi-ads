# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : ConstraintSingleWord.rb
#
# Summary: Implementation of a Constraint which will produce a single
#          string of random characters.

require_relative '../../core/procedure/constraint'
require_relative 'ConstraintSingleWord'

module Maadi
  module Procedure
    class ConstraintMultiWord < ConstraintSingleWord
      attr_accessor :min_words, :max_words, :deliminator

      def initialize( min_length, max_length, min_words, max_words, deliminator )
        super(min_length, max_length)

        @type = 'MULTI-WORD'
        @deliminator = deliminator
        @min_words = [ 0, min_words.to_i ].max
        @max_words = [ min_words.to_i, max_words.to_i ].max
      end

      # attempt to automatically generate a value that would
      # satisfy the constraint
      # return (String) a value that would satisfy the constraint
      def satisfy
        values = Array.new

        length = @min_words
        if @max_words != @min_words
          length = @min_words + rand( @max_words - @min_words ).to_i
        end

        length.times do |number|
          values.push( super )
        end

        return values.join(@deliminator)
      end

      # determine if a specific value satisfies the constraint
      # value (any) value to be tested
      # returns (bool) true, if the constraint is satisfied
      def satisfies?( value )
        if value != nil
          if value.is_a?( String )
            list = value.split(@deliminator)
            return ( ( min_words <= list.length ) && ( list.length <= max_words ) )
          end
        end

        return false
      end
    end
  end
end