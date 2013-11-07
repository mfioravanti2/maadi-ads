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
        @config = Hash.new
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

      # query the monitor to determine if it is ready or has access to system data
      # ** This should be the local implementation! **
      # return N/A
      def update_data

      end
    end
  end
end