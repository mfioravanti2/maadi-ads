
require_relative '../../procedure/procedure'

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

        def process( procedure )
          if procedure != nil
            if procedure.id == @to_procedure
              step = Maadi::Procedure::Step.new( @id, @target, @look_for, @command, Array.new(), @on_fail )
              procedure.add_step( step )
            end
          end

          return procedure
        end
      end
    end
  end
end