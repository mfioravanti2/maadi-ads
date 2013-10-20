# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : RandomSelection.rb
#
# Summary: This is a Random Sampler Organizer.  It simply picks a random
#          element from the possible tests as it's choice and uses that
#          as the selected test to perform.

require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Organizer
    class RandomSelection < Organizer

      def initialize
        super('RandomSelection')
      end

      def supported_domains
        return %w(SQL ADS-STACK ADS-AXIOMATIC-STACK ALGEBRAICADS-STACK ADS-QUEUE ADS-AXIOMATIC-QUEUE ALGEBRAICADS-QUEUE)
      end

      def select_test( tests )
        if tests.instance_of?(Array)
          if tests.length > 0
            return tests.sample
          end
        end

        return ''
      end

      def populate_parameters!( procedure )
        if procedure != nil
          if procedure.is_a?( ::Maadi::Procedure::Procedure )
            procedure.steps.each do |step|
              step.parameters.each do |parameter|
                if ( parameter.value == '' ) && ( parameter.values.length == 0 )
                  parameter.populate_value
                end
              end
            end
          end
        end
      end
    end
  end
end