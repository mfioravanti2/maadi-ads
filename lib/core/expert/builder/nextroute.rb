
require_relative '../../procedure/procedure'

module Maadi
  module Expert
    module Builder
      class NextRoute
        attr_accessor :name

        def initialize(node)
          if node != nil
            @name = node['name']
         end
        end

        def process( procedure )
          if procedure != nil
            if procedure.is_a? Maadi::Procedure::Procedure
              procedure.id = @name
            end
          end

          return procedure
        end
      end
    end
  end
end