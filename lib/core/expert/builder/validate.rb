
require_relative '../../procedure/procedure'

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
      class Validate
        attr_accessor :type, :conditions, :on_success, :on_failure

        def initialize(node)
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
                  process_actions( child )
                else
              end
            end
          end

          puts "Conditions #{@conditions.count}, Actions['Success'] #{@on_success.count}, Actions['Failure'] #{@on_failure.count}"
        end

        def process_conditions( node )
          if node != nil
            node.element_children.each do |condition|
              case condition.name
                when 'condition'
                else
              end
            end
          end
        end

        def process_actions( node )
          if node != nil
            node.element_children.each do |action|
              case action.name
                when 'action'

                  case action['type'].downcase
                    when 'success'
                      add_items( action, @on_success )
                    when 'failure'
                      add_items( action, @on_failure )
                    else
                  end
                else
              end
            end
          end
        end

        def add_items( node, list )
          node.element_children.each do |order|
            case order.name
              when 'add-procedure'
                list.push AddProcedure.new( order )
              when 'add-step'
                list.push AddStep.new( order )
              when 'modify-procedure'
                list.push ModifyProcedure.new( order )
              when 'modify-step'
                list.push ModifyStep.new( order )
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

        def process( procedure )
          if procedure != nil
            if procedure.is_a? Maadi::Procedure::Procedure
              success = 0
              items = nil

              @conditions.each do |condition|
                if condition.test
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
                  procedure = item.process( procedure )
                end
              end
            end
          end

          return procedure
        end
      end
    end
  end
end