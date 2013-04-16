# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : failures.rb
# License: Creative Commons Attribution
#
# Summary: This is a Comparison Analyzer which compares the results from
#          multiple applications and flags deviations as potential failures.

require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Analyzer
    class Failures < Analyzer

      def initialize
        super('Failures')

        @options['SUCCESS'] = 'SUCCESS'

        @notes['SUCCESS'] = 'Key word used to denote success (Analyzer will display other statuses)'
      end

      def analyze
        if @repositories.length > 0
          @repositories.each do |repository|
            Maadi::post_message(:Info, "Analyzer checking (#{repository.to_s}) for results")

            puts
            puts 'Procedures that have failed results'
            list = repository.procedure_ids_by_mismatch

            if list.length > 0
              puts "\tIDs: #{list.join(', ')}"
            else
              puts "\tNo failures found."
            end
          end
        end
      end
    end
  end
end