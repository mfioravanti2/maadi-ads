
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
          if Maadi::Procedure::Procedure.is_procedure?( procedure, @to_procedure )
            step = procedure.get_step( @to_step )

            if Maadi::Procedure::Step.is_step?( step, @to_step )
              parameter = Maadi::Procedure::Parameter.new( @name, nil, '' )
              step.parameters.push parameter
            end

          end

          return procedure
        end
      end
    end
  end
end