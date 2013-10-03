# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 10/01/2013
# File   : modifyparameter.rb
#
# Summary: Builder object to modify a parameter on an existing procedure

require_relative '../../procedure/procedure'

module Maadi
  module Expert
    module Builder
      class ModifyParameter
        attr_accessor :to_procedure, :to_step, :to_parameter, :attribute, :value

        def initialize(node)
          if node != nil
            @to_procedure = node['to_procedure']
            @to_step = node['to_step']
            @to_parameter = node['to_parameter']
            @attribute = node['attribute']
            @value = node['value']
          end
        end

        def process( procedure, expert, model )
          if Maadi::Procedure::Procedure.is_procedure?( procedure, @to_procedure )
            step = procedure.get_step( @to_step )

            if Maadi::Procedure::Step.is_step?( step, @to_step )
              parameter = step.get_parameter( @to_parameter )

              if Maadi::Procedure::Parameter.is_parameter?( parameter, @to_parameter )

                case @attribute
                  when 'label'
                    parameter.label = @value
                  else
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