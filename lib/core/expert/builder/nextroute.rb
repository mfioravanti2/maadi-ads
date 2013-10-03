
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

        def process( procedure, expert, model )
          if Maadi::Procedure::Procedure.is_procedure?( procedure )
            procedure.id = @name
          end

          return procedure
        end
      end
    end
  end
end