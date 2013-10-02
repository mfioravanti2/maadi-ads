
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
          if procedure != nil
            if procedure.is_a? Maadi::Procedure::Procedure
              step = procedure.get_step( @to_step )
              if step != nil
                if step.is_a? Maadi::Procedure::Step
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
              end

            end
          end

          return procedure
        end
      end
    end
  end
end