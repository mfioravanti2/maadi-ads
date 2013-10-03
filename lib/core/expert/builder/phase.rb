# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 10/01/2013
# File   : phase.rb
#
# Summary: Builder object to process a sequence of actions which
#          operate on a procedure.  This is really a container of a
#          list of sequences.

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

        def process( procedure, expert, model )
          if @sequences.count > 0
            @sequences.each do |sequence|
              procedure = sequence.process( procedure, expert, model )
            end
          end

          return procedure
        end
      end
    end
  end
end