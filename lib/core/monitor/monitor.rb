# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : monitor.rb
#
# Summary: The monitor is a way to determine the resources being consumed on
#          a target system.

require_relative '../generic/executable'

module Maadi
  module Monitor
    class Monitor < Maadi::Generic::Executable
      # type (String) is a convenient human readable label.
      def initialize(type)
        super(type)

        @possible_points = Array.new
      end

      # query to get a list of monitor points which are provided by the monitor
      # return (Array of Strings) with a list of the possible points that can be
      #        monitored by this diagnostic tool
      def monitor_points
        return @possible_points
      end

      def get_frequency(point)
        return -1
      end

      def get_offset(point)
        return -1
      end

      def use_point(point, test_id)
        frequency = get_frequency(point)
        offset = get_offset(point)

        if (frequency != -1) && (offset != -1)
          return ( ( ( test_id.to_i + offset ) % frequency ) == 0 )
        end

        return false
      end

      # query to get a list of monitor points that should
      def use_points(test_id)
        points_to_use = Array.new

        points_available = monitor_points
        points_available.each do |point|
          if use_point(point,test_id)
            points_to_use.push(point)
          end
        end

        return points_to_use
      end

      def include_point( point, procedure )
        if @possible_points.include?( point )
          if Maadi::Procedure::Procedure.is_procedure?( procedure )

          end
        end
      end

      def supports_step?( step )
        if Maadi::Procedure::Step.is_step?( step )
          return @possible_points.include?( step.id )
        end

        return false
      end

      def execution_target
        return 'monitor'
      end

      def self.is_monitor?( monitor )
        if monitor != nil
          if monitor.is_a?( Maadi::Monitor::Monitor )
            return true
          end
        end

        return false
      end

      # query the monitor to determine if it is ready or has access to system data
      # return (bool) true if the monitor is ready with system information
      def is_ok?
        return is_ready?
      end
    end
  end
end