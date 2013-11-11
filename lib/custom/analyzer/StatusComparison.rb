# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : comparison.rb
#
# Summary: This is a Comparison Analyzer which compares the results from
#          multiple applications and flags deviations as potential failures.

require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Analyzer
    class StatusComparison < Analyzer

      def initialize
        super('StatusComparison')

        @options['USE_VERTICAL'] = 'TRUE'
        @options['USE_HORIZONTAL'] = 'TRUE'

        @notes['USE_VERTICAL'] = 'Perform a Vertical Comparison (compare results, SAME application DIFFERENT steps)'
        @notes['USE_HORIZONTAL'] = 'Perform a Horizontal Comparison (compare results, DIFFERENT applications, SAME steps)'
      end

      def analyze
        if @repositories.length > 0
          @repositories.each do |repository|
            Maadi::post_message(:Info, "Analyzer (#{@type}:#{@instance_name}) checking (#{repository.to_s}) for results")

            if @options['USE_HORIZONTAL'] == 'TRUE'
              puts
              puts 'PIDs that have statuses which differ between applications'
              list = repository.pids_from_status_mismatch_by_horizontal

              if list.length > 0
                puts "\tIDs: #{list.join(', ')}"
              else
                puts "\tNo Procedural result differences found."
              end
            end

            if @options['USE_VERTICAL'] == 'TRUE'
              puts
              puts 'PIDs that have statuses which differ between steps'
              list = repository.pids_from_status_mismatch_by_vertical( 'EQUALS' )

              if list.length > 0
                puts "\tIDs: #{list.join(', ')}"
              else
                puts "\tNo Procedural result differences found."
              end
            end

            puts
          end
        end
      end
    end
  end
end