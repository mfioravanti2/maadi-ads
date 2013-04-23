# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : set.rb
#
# Summary: CLI commands to activate and configure objects from the CLI configuration

require_relative 'globals'
require_relative 'update'
require_relative '../../custom/factories'

module Maadi
  module CLI
    def self.set_default
      set_item( 'collector', 'SQLite3' )
      set_item( 'collector', 'LogFile' )
      set_item( 'expert', 'SQL' )
      set_item( 'organizer', 'RandomSelection' )
      set_item( 'monitor' )
      set_item( 'application', 'MySQL' )
      set_item( 'scheduler', 'FIFO' )
      set_item( 'analyzer', 'Comparison' )
    end

    def self.set_option( type, instance_name = 'none', option = 'none', value = 'none' )
      case type.downcase
        when 'collector'
          $collectors.each do |collector|
            if collector.instance_name == instance_name
              collector.set_option( option, value )
              Maadi::post_message(:Warn, "Collector (#{collector.to_s}) option #{option} set to #{value}")
            end
          end
        when 'controller'
          if $controller != nil
            $controller.set_option( option, value )
            Maadi::post_message(:Warn, "Controller option #{option} set to #{value}")
          end
        when 'expert'
          if $expert != nil
            $expert.set_option( option, value )
            Maadi::post_message(:Warn, "Expert (#{$expert.to_s}) option #{option} set to #{value}")
          end
        when 'organizer'
          if $organizer != nil
            $organizer.set_option( option, value )
            Maadi::post_message(:Warn, "Organizer (#{$organizer.to_s}) option #{option} set to #{value}")
          end
        when 'scheduler'
          if $scheduler != nil
            $scheduler.set_option( option, value )
            Maadi::post_message(:Warn, "Scheduler (#{$scheduler.to_s}) option #{option} set to #{value}")
          end
        when 'application'
          $applications.each do |application|
            if application.instance_name == instance_name
              application.set_option( option, value )
              Maadi::post_message(:Warn, "Application (#{application.to_s}) option #{option} set to #{value}")
            end
          end
        when 'monitor'
          $monitors.each do |monitor|
            if monitor.instance_name == instance_name
              monitor.set_option( option, value )
              Maadi::post_message(:Warn, "Monitor (#{monitor.to_s}) option #{option} set to #{value}")
            end
          end
        when 'tasker'
          $taskers.each do |tasker|
            if tasker.instance_name == instance_name
              tasker.set_option( option, value )
              Maadi::post_message(:Warn, "Tasker (#{tasker.to_s}) option #{option} set to #{value}")
            end
          end
        when 'analyzer'
          if $analyzer != nil
            $analyzer.set_option( option, value )
            Maadi::post_message(:Warn, "Analyzer (#{$analyzer.to_s}) option #{option} set to #{value}")
          end
        when 'manager'
          if $manager != nil
            $manager.set_option( option, value )
            Maadi::post_message(:Warn, "Manager (#{$manager.to_s}) option #{option} set to #{value}")
          end
        else
      end
    end

    def self.set_item( type, value = 'default', instance_name = 'none' )
      case type.downcase
        when 'runs'
          begin
            $runs = value.to_i
          rescue
            Maadi::post_message(:Warn, "Unable to extract integer from #{value}")
            $runs = 100
          end

          if $runs < 1
            $runs = 1
          end
          Maadi::post_message(:Warn, "Runs set to #{$runs}")

          if $controller != nil
            $controller.runs = $runs
          end
        when 'collector'
          collector = Maadi::Collector::Collector.factory( ( value == 'default' ) ? 'SQLite3' : value )
          if collector != nil
            if instance_name != 'none'
              collector.instance_name = instance_name
            end

            $collectors.push collector

            # If the collector has been reset, then the Controller and the Manager need to be re-initialized
            $controller = nil
            $manager = nil
          end
        when 'expert'
          if $expert == nil
            $expert = Expert::Expert.factory( ( value == 'default' ) ? 'Example' : value )
            if instance_name != 'none'
              $expert.instance_name = instance_name
            end

            # If the Expert has been reset, then the Generator, Controller, and Manager need to be re-initialized
            $generator = nil
            $controller = nil
            $manager = nil
          else
            Maadi::post_message(:Warn, "Expert already specified, use 'unset expert' to remove first")
          end
        when 'organizer'
          if $organizer == nil
            $organizer = Organizer::Organizer.factory( ( value == 'default' ) ? 'Example' : value )
            if instance_name != 'none'
              $organizer.instance_name = instance_name
            end

            # If the Organizer has been reset, then the Generator, Controller, and Manager need to be re-initialized
            $generator = nil
            $controller = nil
            $manager = nil
          else
            Maadi::post_message(:Warn, "Organizer already specified, use 'unset organizer' to remove first")
          end
        when 'monitor'
          monitor = Monitor::Monitor.factory( ( value == 'default' ) ? 'Example' : value )
          if monitor != nil
            if instance_name != 'none'
              monitor.instance_name = instance_name
            end

            $monitors.push monitor

            # If the Monitor has been reset, then the Controller and Manager needs to be re-initialized
            $controller = nil
            $manager = nil
          end
        when 'tasker'
          tasker = Tasker::Tasker.factory( ( value == 'default' ) ? 'Example' : value )
          if tasker != nil
            if instance_name != 'none'
              tasker.instance_name = instance_name
            end

            $taskers.push tasker

            # If the Monitor has been reset, then the Controller and Manager needs to be re-initialized
            $controller = nil
            $manager = nil
          end
        when 'scheduler'
          if $scheduler == nil
            $scheduler = Scheduler::Scheduler.factory( ( value == 'default' ) ? 'FIFO' : value )
            if instance_name != 'none'
              $scheduler.instance_name = instance_name
            end

            # If the Monitor has been reset, then the Controller and Manager needs to be re-initialized
            $controller = nil
            $manager = nil
          else
            post_message(:Warn, "Scheduler already specified, use 'unset scheduler' to remove first")
          end
        when 'application'
          application = Application::Application.factory( ( value == 'default' ) ? 'Example' : value )
          if application != nil
            if instance_name != 'none'
              application.instance_name = instance_name
            end

            $applications.push application

            # If the collector has been reset, then the Controller and the Manager need to be re-initialized
            $controller = nil
            $manager = nil
          end
        when 'analyzer'
          $analyzer = Analyzer::Analyzer.factory( ( value == 'default' ) ? 'Example' : value )
          if instance_name != 'none'
            $analyzer.instance_name = instance_name
          end

          # If the Analyzer has been reset, then the Manager needs to be re-initialized
          $manager = nil

        else
          Maadi::post_message(:Warn, "Incorrect usage, #{type} is an unrecognized option")
      end

      refresh_items( type )
    end
  end
end

