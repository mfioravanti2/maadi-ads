
require_relative 'sequence'

module Maadi
  module Expert
    module Builder
      class Phase
        attr_accessor :id, :name, :sequences

        def initialize(node)
          @sequences = Array.new

          if node != nil
            @id = node['id']
            @name = node['name']

            node.element_children.each do |sequence|
              @sequences.push  Sequence.new(sequence)
            end
          end
        end

        def process( procedure )
          if @sequences.count > 0
            @sequences.each do |sequence|
              procedure = sequence.process( procedure )
            end
          end

          return procedure
        end
      end
    end
  end
end