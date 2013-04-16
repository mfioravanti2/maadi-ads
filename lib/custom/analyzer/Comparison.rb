# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : comparison.rb
# License: Creative Commons Attribution
#
# Summary: This is a Comparison Analyzer which compares the results from
#          multiple applications and flags deviations as potential failures.

require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Analyzer
    class Comparison < Analyzer

      def initialize
        super('Comparison')
      end

      def analyze
        if @repositories.length > 0
          @repositories.each do |repository|
            Maadi::post_message(:Info, "Analyzer (#{repository.to_s}) Results")

            puts
            puts 'Procedures that have results which differ between applications'
            list = repository.procedure_ids_by_mismatch

            if list.length > 0
              puts "\tIDs: #{list.join(', ')}"
            else
              puts "\tNo Procedural result differences found."
            end
          end
        end
      end
    end
  end
end