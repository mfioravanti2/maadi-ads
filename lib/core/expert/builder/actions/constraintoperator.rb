# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 10/01/2013
# File   : constraintparameter.rb
#
# Summary: Builder object to add a constraint to a procedure

module Maadi
  module Expert
    module Builder
      class ConstraintOperator
        attr_accessor :name, :source, :value, :type, :node, :operators

        def initialize( node, expert, model )
          @node = node
          @operators = Array.new

          if @node != nil
            @name = @node['name']
            @source = @node['source']
            @type = @node['type']

            item = nil
            case @source.downcase
              when 'specified'
                item = @node['value']
              when 'expert'
                if Maadi::Expert::Expert.is_expert?( expert )
                  item = expert.get_option( @value )
                end
              when 'model'
                if Maadi::Expert::Models::Model.is_model?( model )
                  item = model.get_value( @value )
                end
              else
            end

            case @type.downcase
              when 'integer'
                @value = item.to_i
              when 'float'
                @value = item.to_f
              when 'bool'
                @value = item.to_b
              else
                @value = item
            end
          end
        end
      end
    end
  end
end