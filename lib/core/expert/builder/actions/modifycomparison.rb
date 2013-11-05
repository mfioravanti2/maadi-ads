# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 10/01/2013
# File   : modifystep.rb
#
# Summary: Builder object to modify a step on an existing procedure

require_relative '../../../procedure/procedure'

module Maadi
  module Expert
    module Builder
      class ModifyComparison
        attr_accessor :to_comparison, :attribute, :value

        def initialize(node)
          if node != nil
            @to_comparison = node['to_comparison']
            @attribute = node['attribute']
            @value = node['value']
          end
        end

        def process( procedure, expert, model )
          if Maadi::Procedure::Procedure.is_procedure?( procedure )
            comparison = procedure.get_comparison( @to_comparison )

            if Maadi::Procedure::Comparison.is_comparison?( comparison )
              case @attribute
                when 'name'
                  comparison.id = @value
                when 'relationship'
                  comparison.relationship = @value
                when 'remove-compare'
                  #step.look_for = @value
                when 'add-compare'
                  #step.command = @value
                else
              end
            end

            return procedure
          end
        end
      end
    end
  end
end