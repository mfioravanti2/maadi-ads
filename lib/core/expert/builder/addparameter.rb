
require_relative '../../procedure/procedure'

module Maadi
  module Expert
    module Builder
      class AddParameter
        attr_accessor :to_procedure, :to_step, :name

        def initialize(node)
          if node != nil
            @to_procedure = node['to_procedure']
            @to_step = node['to_step']
            @name = node['name']
          end
        end

        def process( procedure, expert, model )
          if procedure != nil
            if procedure.id == @to_procedure
              step = procedure.get_step( @to_step )
              if step != nil
                if step.id == @to_step
                  parameter = Maadi::Procedure::Parameter.new( @name, nil, '' )
                  step.parameters.push parameter
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