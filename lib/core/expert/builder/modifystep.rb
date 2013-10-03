
require_relative '../../procedure/procedure'

module Maadi
  module Expert
    module Builder
      class ModifyStep
        attr_accessor :to_step, :attribute, :value

        def initialize(node)
          if node != nil
            @to_step = node['to_step']
            @attribute = node['attribute']
            @value = node['value']
          end
        end

        def process( procedure, expert, model )
          if Maadi::Procedure::Procedure.is_procedure?( procedure )
            step = procedure.get_step( @to_step )

            if Maadi::Procedure::Step.is_step?( step, @to_step )
              case @attribute
                when 'name'
                  step.id = @value
                when 'target'
                  step.target = @value
                when 'look_for'
                  step.look_for = @value
                when 'command'
                  step.command = @value
                when 'on_failure'
                  step.on_fail = @value
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