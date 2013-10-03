# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 10/01/2013
# File   : modifymodel.rb
#
# Summary: Builder object to modify a value in the model

require_relative '../../procedure/procedure'

module Maadi
  module Expert
    module Builder
      class ModifyModel
        attr_accessor :name

        def initialize(node)
          if node != nil
            @name = node['name']
          end
        end

        def process( procedure, expert, model )
          if Maadi::Procedure::Procedure.is_procedure?( procedure )

          end

          return procedure
        end
      end
    end
  end
end