# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 10/01/2013
# File   : addstep.rb
#
# Summary: Builder object to add a step to a procedure

require_relative '../../../procedure/procedure'

module Maadi
  module Expert
    module Builder
      class AddComparison
        attr_accessor :to_procedure, :id, :relationship, :comparisons

        def initialize(node)
          if node != nil
            @id = node['name']
            @to_procedure = node['to_procedure']
            @relationship = node['relationship']
            @comparisons = Array.new()

            node.element_children.each do |item|
              case item.name
                when 'compare-item'
                  @comparisons.push item['step']
                else
              end
            end
          end
        end

        def process( procedure, expert, model )
          if Maadi::Procedure::Procedure.is_procedure?( procedure, @to_procedure )
              comparison = Maadi::Procedure::Comparison.new( @id, Array.new, @relationship )

              @comparisons.each do |item|
                step = procedure.get_step( item )
                if Maadi::Procedure::Step.is_step?( step, item )
                  comparison.steps.push step
                end
              end

              procedure.comparisons.push comparison
          end

          return procedure
        end
      end
    end
  end
end