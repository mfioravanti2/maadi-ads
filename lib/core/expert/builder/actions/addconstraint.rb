# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 10/01/2013
# File   : addconstraint.rb
#
# Summary: Builder object to add a constraint to a procedure

require_relative '../../../procedure/procedure'

require_relative '../../../../custom/procedure/ConstraintRangedInteger'

module Maadi
  module Expert
    module Builder
      class AddConstraint
        attr_accessor :to_procedure, :to_step, :to_parameter, :type, :node

        def initialize(node)
          @node = node

          if @node != nil
            @to_procedure = @node['to_procedure']
            @to_step = @node['to_step']
            @to_parameter = @node['to_parameter']
            @type = @node['type']
          end
        end

        def process( procedure, expert, model )
          if Maadi::Procedure::Procedure.is_procedure?( procedure, @to_procedure )
            step = procedure.get_step( @to_step )

            if Maadi::Procedure::Step.is_step?( step, @to_step )
              parameter = step.get_parameter( @to_parameter )

              if Maadi::Procedure::Parameter.is_parameter?( parameter, @to_parameter )
                case @type.downcase
                  when 'ranged-integer'

                    min_value = @node['min_range']
                    if min_value.include?( 'OPTIONS:' ) && expert != nil
                      key = min_value.sub( 'OPTION:', '' ).to_s
                      min_value = expert.get_option( key )
                    end

                    max_value = @node['max_range']
                    if max_value.include?( 'OPTIONS:' ) && expert != nil
                      key = max_value.sub( 'OPTIONS:', '' ).to_s
                      max_value = expert.get_option( key )
                    end

                    constraint = Maadi::Procedure::ConstraintRangedInteger.new( min_value, max_value  )
                    parameter.constraint = constraint
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