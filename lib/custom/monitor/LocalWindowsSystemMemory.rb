# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : LocalWindowsProcessModules.rb
#
# Summary: This is a Local Windows System Memory Monitor

require 'rubygems'
require 'json'
require 'open3'

require_relative 'factory'
require_relative '../../core/helpers'

class Array
  def integer_sum
    sum = 0
    self.map{|x| sum += x.to_i}
    return sum
  end
end

module Maadi
  module Monitor
    class LocalWindowsSystemMemory < Monitor

      def initialize
        super('LocalWindowsSystemMemory')

        @possible_points = %w(TOTAL-PHYSICAL AVAILABLE-PHYSICAL TOTAL-VIRTUAL AVAILABLE-PHYSICAL TOTAL-PAGING AVAILABLE-PAGING)

        @possible_points.each do |item|
          @options["USE-#{item}"] = 'TRUE'
          @options["#{item}-FREQ"] = 20
          @options["#{item}-OFFSET"] = 0

          friendly = item.split(/(\W)/).map(&:capitalize)

          @notes["USE-#{item}"] = "Use the Monitor to determine the #{friendly.join(' ')} Memory on the System"
          @notes["#{item}-FREQ"] = "Frequency at which to check the #{friendly.join(' ')} Memory (TID + OFFSET) MOD FREQUENCY"
          @notes["#{item}-OFFSET"] = "Offset at which to check the #{friendly.join(' ')} Memory (TID + OFFSET) MOD FREQUENCY"
        end

        @options['MONITOR-PATH'] = '../utils/bin/windows/monitors/'
        @options['MONITOR-NAME'] = 'Monitor-SysMemory.exe'

        @notes['MONITOR-PATH'] = 'Directory of the System Memory Monitor'
        @notes['MONITOR-NAME'] = 'Filename of the System Memory Monitor'

        @ready = false
      end

      def monitor_points
        items = Array.new

        @possible_points.each do |item|
          if @options["USE-#{item}"] == 'TRUE'
            items.push item
          end
        end

        return items
      end

      def get_frequency(point)
        if @possible_points.include?( point )
          return  @options["#{point}-FREQ"].to_i
        end

        return -1
      end

      def get_offset(point)
        if @possible_points.include?( point )
          return  @options["#{point}-OFFSET"].to_i
        end

        return -1
      end

      def is_ok?
        return @ready
      end

      def prepare
        begin

          path_file = "#{@options['MONITOR-PATH']}#{@options['MONITOR-NAME']}"
          unless File.exists?( path_file )
            Maadi::post_message(:Warn, "Monitor (#{@type}:#{@instance_name}) was unable to locate monitor (path_file).")
            @ready = false
            return false
          end

          super
        rescue => e
          Maadi::post_message(:Warn, "Monitor (#{@type}:#{@instance_name}) was unable to initialize (#{e.message}).")
        end
      end

      def include_point( point, procedure )
        if @possible_points.include?( point )
          if Maadi::Procedure::Procedure.is_procedure?( procedure )
            step = Maadi::Procedure::Step.new( point, 'monitor', 'RVALUE', '', Array.new(), 'TERM-PROC')
            procedure.add_step( step )
          end
        end
      end

      def execute( test_id, procedure )
        results = Maadi::Procedure::Results.new( test_id.to_i, 0, "#{@type}:#{@instance_name}", nil )

        if Maadi::Procedure::Procedure.is_procedure?( procedure )
          results.proc_id = procedure.id

          mem_cmd = 'D:/Code/C++/Monitor-SysMemory/Debug/Monitor-SysMemory.exe'
          json_text = ''
          Open3.popen3(mem_cmd) do |stdin, stdout, stderr, wait_thr|
            json_text = stdout.read
          end

          json_obj = JSON.parse( json_text )

          procedure.steps.each do |step|
            if step.target == execution_target
              if supports_step?( step )
                rValue = -1
                rType = 'INTEGER'

                bSuccess = true
                bError = false

                case step.id
                  when 'TOTAL-PHYSICAL'
                    rValue = json_obj['physical']['total']['size']
                  when 'AVAILABLE-PHYSICAL'
                    rValue = json_obj['physical']['free']['size']
                  when 'TOTAL-VIRTUAL'
                    rValue = json_obj['virtual']['total']['size']
                  when 'AVAILABLE-PHYSICAL'
                    rValue = json_obj['virtual']['free']['size']
                  when 'TOTAL-PAGING'
                    rValue = json_obj['paging']['total']['size']
                  when 'AVAILABLE-PAGING'
                    rValue = json_obj['paging']['free']['size']
                  else
                end

                begin
                  case step.look_for
                    when 'NORECORD'
                    when 'RVALUE'
                      results.add_result( Maadi::Procedure::Result.new( step, rValue.to_s, rType, ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                    else
                      results.add_result( Maadi::Procedure::Result.new( step, step.look_for, 'TEXT', 'UNKNOWN' ))
                  end
                rescue => e
                  Maadi::post_message(:Warn, "Monitor (#{@type}:#{@instance_name}) encountered an error (#{e.message}).")
                  results.add_result( Maadi::Procedure::Result.new( step, e.message, 'TEXT', 'EXCEPTION' ))
                end
              else
                Maadi::post_message(:Warn, "Monitor (#{@type}:#{@instance_name}) encountered an unsupported step (#{procedure.id}, #{step.id}).")
              end
            end
          end
        end

        return results
      end

      def teardown
        super
      end

    end
  end
end