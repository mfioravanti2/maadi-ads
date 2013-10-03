# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 10/01/2013
# File   : addprocedure.rb
#
# Summary: Builder object to add create a new procedure

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