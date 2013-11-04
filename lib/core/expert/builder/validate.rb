# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 10/01/2013
# File   : validate.rb
#
# Summary: Builder object to validate the state of a procedure

require_relative '../../procedure/procedure'

require_relative 'actions/addprocedure'
require_relative 'actions/addstep'
require_relative 'actions/addparameter'
require_relative 'actions/addconstraint'
require_relative 'actions/addcomparison'
require_relative 'actions/modifyprocedure'
require_relative 'actions/modifystep'
require_relative 'actions/modifyparameter'
require_relative 'actions/modifyconstraint'
require_relative 'actions/modifymodel'
require_relative 'actions/nextroute'

require_relative 'conditions/conditionexists'

module Maadi
  module Expert
    module Builder
      class Validate
        attr_accessor :type, :conditions, :on_success, :on_failure

        def initialize( node, expert, model)
          @conditions = Array.new
          @on_success = Array.new
          @on_failure = Array.new

          if node != nil
            @type = node['type']

            node.element_children.each do |child|
              case child.name
                when 'conditions'
                  process_conditions( child )
                when 'actions'
                  process_actions( child, expert, model )
                else
              end
            end
          end
        end

        def process_conditions( node )
          if node != nil
            node.element_children.each do |condition|
              case condition.name
                when 'condition'
                  case condition['type'].downcase
                    when 'exists'
                      @conditions.push  Maadi::Expert::Builder::Conditions::ConditionExists.new( condition )
                    else
                  end
                else
              end
            end
          end
        end

        def process_actions( node, expert, model )
          if node != nil
            node.element_children.each do |action|
              case action.name
                when 'action'

                  case action['type'].downcase
                    when 'success'
                      add_items( action, @on_success, expert, model )
                    when 'failure'
                      add_items( action, @on_failure, expert, model )
                    else
                  end
                else
              end
            end
          end
        end

        def add_items( node, list, expert, model )
          node.element_children.each do |order|
            case order.name
              when 'add-procedure'
                list.push AddProcedure.new( order )
              when 'add-step'
                list.push AddStep.new( order )
              when 'add-parameter'
                list.push AddParameter.new( order )
              when 'add-constraint'
                list.push AddConstraint.new( order, expert, model )
              when 'add-comparison'
                list.push AddComparison.new( model )
              when 'modify-procedure'
                list.push ModifyProcedure.new( order )
              when 'modify-step'
                list.push ModifyStep.new( order )
              when 'modify-parameter'
                list.push ModifyParameter.new( order )
              when 'modify-constraint'
                list.push ModifyConstraint.new( order, expert, model )
              when 'modify-model'
                list.push ModifyModel.new( order )
              when 'next-route'
                list.push NextRoute.new( order )
              when 'validate'
                list.push Validate.new( order )
              else
            end
          end
        end

        def process( procedure, expert, model )
          if Maadi::Procedure::Procedure.is_procedure?( procedure )
            success = 0
            items = nil

            @conditions.each do |condition|
              if condition.test( procedure, expert, model )
                success += 1
              end
            end

            if success == @conditions.count
              items = @on_success
            else
              items = @on_failure
            end

            if items.count > 0
              items.each do |item|
                procedure = item.process( procedure, expert, model )
              end
            end
          end

          return procedure
        end
      end
    end
  end
end