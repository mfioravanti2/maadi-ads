# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 10/01/2013
# File   : addstep.rb
#
# Summary: Builder object to add a step to a procedure

require_relative '../../../procedure/procedure'

module Maadi
  module Expert
    module Builder
      class AddStep
        attr_accessor :to_procedure, :id, :target, :look_for, :command, :on_fail

        def initialize(node)
          if node != nil
            @to_procedure = node['to_procedure']
            @id = node['name']
            @target = node['target']
            @look_for = node['look_for']
            @command = node['command']
            @on_fail = node['on_failure']
          end
        end

        def process( procedure, expert, model )
          if Maadi::Procedure::Procedure.is_procedure?( procedure, @to_procedure )
              step = Maadi::Procedure::Step.new( @id, @target, @look_for, @command, Array.new(), @on_fail )
              procedure.add_step( step )
          end

          return procedure
        end
      end
    end
  end
end