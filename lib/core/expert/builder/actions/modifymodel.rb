# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 10/01/2013
# File   : modifymodel.rb
#
# Summary: Builder object to modify a value in the model

require_relative '../../../procedure/procedure'

module Maadi
  module Expert
    module Builder
      class ModifyModel
        attr_accessor :attribute, :type, :operation, :value

        def initialize(node)
          if node != nil
            @attribute = node['attribute']
            @type = node['type']
            @operation = node['operation']
            @value = node['value']
          end
        end

        def process( procedure, expert, model )
          if Maadi::Expert::Models::Model.is_model?( model )
            case @operation.downcase
              when 'specify'
                model.set_value( @attribute, @type.upcase, @value )
              when 'increment'
                model.operate_on_value( @attribute, @type.upcase, @operation.upcase, @value )
              when 'decrement'
                model.operate_on_value( @attribute, @type.upcase, @operation.upcase, @value )
              else
            end
          end

          return procedure
        end
      end
    end
  end
end