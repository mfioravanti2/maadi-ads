# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : ConstraintPickList.rb
#
# Summary: Implementation of a Constraint which will produce
#          random subset of items from a provided list.

require_relative '../../core/procedure/constraint'

module Maadi
  module Procedure
    class ConstraintMultiPickList < Constraint
      attr_accessor :items, :count

      def initialize( count, items )
        super('MULTI-PICK-LIST')
        @items = items

        # ensure that more items cannot be picked than are available on the list
        max_size = [ items.length, count.to_i ].min
        @count = [ max_size.to_i, 1].max
      end

      # attempt to automatically generate a value that would
      # satisfy the constraint
      # return (Array of Strings) a value that would satisfy the constraint
      def satisfy
        if @items.instance_of?(Array)
          if @items.length > 0
            return @items.sample(@count)
          end
        end

        return Array.new
      end

      # determine if a specific value satisfies the constraint
      # value (any) value to be tested
      # returns (bool) true, if the constraint is satisfied
      def satisfies?( value )
        if value != nil
          if value.is_a?( Array )
            return ( @items - value ).empty?
          end
        end

        return false
      end
    end
  end
end