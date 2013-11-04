# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : comparison.rb
#
# Summary: Constraints serve as objects to limit and generate values
#          within a set of constraints.  For example a constraint
#          could be generate a random integer between 5 and 12.

module Maadi
  module Procedure
    class Comparison
      attr_accessor :id, :steps, :relationship

      def initialize(id, steps, relationship)
        @id = id
        @steps = steps
        @relationship = relationship

        if @steps == nil
          @steps = Array.new
        end
      end

      def self.is_comparison?( comparison )
        if comparison != nil
          if comparison.is_a?( Maadi::Procedure::Comparison )
              return true
          end
        end

        return false
      end
    end
  end
end