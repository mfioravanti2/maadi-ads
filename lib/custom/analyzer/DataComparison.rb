# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 01/18/2013
# File   : differences.rb
#
# Summary: This is a Comparison Analyzer which compares the results from
#          multiple applications and flags deviations as potential failures.

require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Analyzer
    class DataComparison < Analyzer

      def initialize
        super('DataComparison')

        @options['INTEGER_EPSILON'] = 0
        @options['FLOAT_EPSILON'] = 0.5
        @options['TEXT_EPSILON'] = 'EXACT'

        @notes['INTEGER_EPSILON'] = 'Epsilon value between two INTEGERS which the values are considered the same'
        @notes['FLOAT_EPSILON'] = 'Epsilon value between two FLOATS which the values are considered the same'
        @notes['TEXT_EPSILON'] = 'Epsilon value between two TEXT strings which the values are considered the same'

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
              types = repository.types
              types.each do |type|
                list = Array.new
                if @options["#{type.upcase}_EPSILON"] != 'EXACT'
                  list = repository.pids_from_delta_data_by_horizontal( type, @options["#{type.upcase}_EPSILON"] )
                else
                  list = repository.pids_from_data_by_horizontal( type )
                end

                puts
                puts "PIDs that have results which differ between applications (with type = #{type})"

                if list.length > 0
                  puts "\tIDs: #{list.join(', ')}"
                else
                  puts "\tNo Procedural result differences found."
                end
              end
            end

            if @options['USE_VERTICAL'] == 'TRUE'
              types = repository.types
              types.each do |type|
                list = Array.new
                if @options["#{type.upcase}_EPSILON"] != 'EXACT'
                  list = repository.pids_from_delta_data_by_vertical( type, @options["#{type.upcase}_EPSILON"], 'EQUALS' )
                else
                  list = repository.pids_from_data_by_vertical( type, 'EQUALS' )
                end

                puts
                puts "PIDs that have results which differ between steps (with type = #{type})"

                if list.length > 0
                  puts "\tIDs: #{list.join(', ')}"
                else
                  puts "\tNo Procedural result differences found."
                end
              end
            end

            puts
          end
        end
      end
    end
  end
end