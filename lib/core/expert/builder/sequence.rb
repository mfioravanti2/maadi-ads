# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 10/01/2013
# File   : sequence.rb
#
# Summary: Builder object to modify as aspect of a procedure

require_relative '../../procedure/procedure'

require_relative 'actions/addprocedure'
require_relative 'actions/addstep'
require_relative 'actions/addparameter'
require_relative 'actions/addconstraint'
require_relative 'actions/modifyprocedure'
require_relative 'actions/modifystep'
require_relative 'actions/modifyparameter'
require_relative 'actions/modifyconstraint'
require_relative 'actions/modifymodel'
require_relative 'actions/nextroute'

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
              when 'add-parameter'
                @items.push AddParameter.new( order )
              when 'add-constraint'
                @items.push AddConstraint.new( order )
              when 'modify-procedure'
                @items.push ModifyProcedure.new( order )
              when 'modify-step'
                @items.push ModifyStep.new( order )
              when 'modify-parameter'
                @items.push ModifyParameter.new( order )
              when 'modify-constraint'
                @items.push ModifyConstraint.new( order )
              when 'next-route'
                @items.push NextRoute.new( order )
              when 'validate'
                @items.push Validate.new( order )
              else
            end
          end
        end

        def process( procedure, expert, model )
          if @items.count > 0
            @items.each do |item|
              procedure = item.process( procedure, expert, model )
            end
          end

          return procedure
        end
      end
    end
  end
end