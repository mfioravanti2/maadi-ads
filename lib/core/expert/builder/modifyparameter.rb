
require_relative '../../procedure/procedure'

module Maadi
  module Expert
    module Builder
      class ModifyParameter
        attr_accessor :attribute, :value

        def initialize(node)
          if node != nil
            @attribute = node['attribute']
            @value = node['value']
          end
        end

        def process( procedure, expert, model )
          if procedure != nil
            if procedure.is_a? Maadi::Procedure::Procedure
              case @attribute
                when 'name'
                  procedure.id = @value
                else
              end
            end
          end

          return procedure
        end
      end
    end
  end
end