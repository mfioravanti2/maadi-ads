
require_relative '../../procedure/procedure'

module Maadi
  module Expert
    module Builder
      class AddProcedure
        attr_accessor :id

        def initialize(node)
          if node != nil
            @id = node['name']
          end
        end

        def process( procedure, expert, model )
          procedure = Maadi::Procedure::Procedure.new( @id )
          return procedure
        end
      end
    end
  end
end