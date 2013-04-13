# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : ConstraintPickList.rb
# License: Creative Commons Attribution
#
# Summary: Implementation of a Constraint which will produce a single
#          string of random characters.

require_relative '../../core/procedure/constraint'

module Maadi
  module Procedure
    class ConstraintPickList < Constraint
      attr_accessor :items

      def initialize( items )
        super('PICK-LIST')

        @items = Array.new
        if items != nil
          if items.is_a?( Array )
            @items = items
          end
        end
      end

      # obtain a detailed printable version of the constraint
      # return (String) detailed string representing the constraint
      def display
        return "#{@type} (CHOOSE ONE: #{@items.join(', ')})"
      end


      # attempt to automatically generate a value that would
      # satisfy the constraint
      # return (String) a value that would satisfy the constraint
      def satisfy
        if @items.instance_of?(Array)
          if @items.length > 0
            return @items.sample
          end
        end

        return ''
      end

      # determine if a specific value satisfies the constraint
      # value (any) value to be tested
      # returns (bool) true, if the constraint is satisfied
      def satisfies?( value )
        if value != nil
          if value.is_a?( String )
            return @items.include?( value )
          end
        end

        return false
      end
    end
  end
end