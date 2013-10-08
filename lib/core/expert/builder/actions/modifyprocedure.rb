# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 10/01/2013
# File   : modifyprocedure.rb
#
# Summary: Builder object to modify  an existing procedure

require_relative '../../../procedure/procedure'

module Maadi
  module Expert
    module Builder
      class ModifyProcedure
        attr_accessor :attribute, :value

        def initialize(node)
          if node != nil
            @attribute = node['attribute']
            @value = node['value']
          end
        end

        def process( procedure, expert, model )
          if Maadi::Procedure::Procedure.is_procedure?( procedure )
            case @attribute
              when 'name'
                procedure.id = @value
              else
            end
          end

          return procedure
        end
      end
    end
  end
end