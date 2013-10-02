
require_relative 'addprocedure'
require_relative 'addstep'
require_relative 'modifyprocedure'
require_relative 'modifystep'
require_relative 'modifymodel'
require_relative 'nextroute'
require_relative 'validate'

module Maadi
  module Expert
    module Builder
      class Sequence
        attr_accessor :id, :on_failure

        def initialize(node)
          @items = Array.new

          node.element_children.each do |order|
            case order.name
              when 'add-procedure'
                @items.push AddProcedure.new( order )
              when 'add-step'
                @items.push AddStep.new( order )
              when 'modify-procedure'
                @items.push ModifyProcedure.new( order )
              when 'modify-step'
                @items.push ModifyStep.new( order )
              when 'next-route'
                @items.push NextRoute.new( order )
              when 'validate'
                @items.push Validate.new( order )
              else
            end
          end
        end

        def process( procedure )
          if @items.count > 0
            @items.each do |item|
              procedure = item.process( procedure )
            end
          end

          return procedure
        end
      end
    end
  end
end