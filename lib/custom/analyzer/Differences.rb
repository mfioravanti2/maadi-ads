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
    class Differences < Analyzer

      def initialize
        super('Differences')

        @options['INTEGER_EPSILON'] = 0
        @options['FLOAT_EPSILON'] = 0.5
        @options['TEXT_EPSILON'] = 'EXACT'
      end

      def analyze
        if @repositories.length > 0
          @repositories.each do |repository|
            Maadi::post_message(:Info, "Analyzer (#{@type}:#{@instance_name}) checking (#{repository.to_s}) for results")

            types = repository.types
            types.each do |type|
              list = Array.new
              if @options["#{type.upcase}_EPSILON"] != 'EXACT'
                list = repository.procedure_ids_by_delta( type, @options["#{type.upcase}_EPSILON"] )
              else
                list = repository.procedure_ids_by_compare( type )
              end

              puts
              puts "Procedures that have results which differ between applications (with type = #{type})"

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
end