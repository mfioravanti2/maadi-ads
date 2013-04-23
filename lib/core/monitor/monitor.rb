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
        setup_data
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

      # query the monitor to determine the total available physical memory on the system
      # return (Integer) available physical memory on the system (in bytes)
      def total_physical_memory
        return @config['hw']['memory']['physical']['total']
      end

      # query the monitor to determine the total virtual memory on the system
      # return (Integer) available virtual memory on the system (in bytes)
      def total_virtual_memory
        return @config['hw']['memory']['virtual']['total']
      end

      # query the monitor to determine the total physical memory in use on the system
      # return (Integer) physical memory in use on the system (in bytes)
      def used_physical_memory
        return @config['hw']['memory']['physical']['used']
      end

      # query the monitor to determine the total virtual memory in use on the system
      # return (Integer) virtual memory in use on the system (in bytes)
      def used_virtual_memory
        return @config['hw']['memory']['virtual']['used']
      end

      # query the monitor to determine the name of the platform
      # return (String) platform name
      def platform_name
        return @config['os']['platform']['name']
      end

      # query the monitor to determine the platform version
      # return (String) platform version
      def platform_version
        return @config['os']['platform']['version']
      end

      # query the monitor to determine the average CPU load
      # return (Float) average CPU load (percentage)
      def cpu_load
        return @config['hw']['cpu']['load']
      end

      # query the monitor to determine the system's hostname
      # return (String) system's hostname
      def host_name
        return @config['os']['host']['name']
      end

      # query the monitor to determine the username of the account which the system is utilizing
      # return (String) processes' username
      def user_name
        return @config['os']['user']['name']
      end

      private
      def setup_data
        @config['hw'] = Hash.new
        @config['hw']['memory'] = Hash.new
        @config['hw']['memory']['physical'] = { 'total' => 0, 'used' => 0 }
        @config['hw']['memory']['virtual'] = { 'total' => 0, 'used' => 0 }

        @config['hw']['cpu'] = Hash.new
        @config['hw']['cpu']['load'] = 0.0
        @config['hw']['cpu']['processors'] = 0

        @config['os'] = Hash.new
        @config['os']['platform'] = { 'name' => '', 'version' => '', 'update' => ''}
        @config['os']['host'] = { 'name' => '' }
        @config['os']['user'] = { 'name' => '' }
      end
    end
  end
end