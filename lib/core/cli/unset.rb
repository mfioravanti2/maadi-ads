# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : unset.rb
#
# Summary: CLI commands to remove components from the CLI configuration

require_relative 'globals'
require_relative 'update'

module Maadi
  module CLI
    def self.unset_item( type, value = 'default' )
      case type.downcase
        when 'collector'
          $collectors.each do |collector|
            if ( collector.type == value ) || ( collector.instance_name == value )
              $collectors.delete( collector )
              Maadi::post_message( :Less, "Collector #{collector.type} (#{collector.to_s}) has been removed")

              # If the collector has been reset, then the Controller and the Manager need to be re-initialized
              $controller = nil
              $manager = nil
            end
          end
        when 'expert'
          Maadi::post_message( :Less, "Expert #{$expert.type} (#{$expert.to_s}) has been removed")
          $expert = nil

          # If the Expert has been reset, then the Generator, Controller, and Manager need to be re-initialized
          $generator = nil
          $controller = nil
          $manager = nil
        when 'organizer'
          Maadi::post_message( :Less, "Organizer #{$organizer.type} (#{$organizer.to_s}) has been removed")
          $organizer = nil

          # If the Organizer has been reset, then the Generator, Controller, and Manager need to be re-initialized
          $generator = nil
          $controller = nil
          $manager = nil
        when 'monitor'
          $monitors.each do |monitor|
            if ( monitor.type == value ) || ( monitor.instance_name == value )
              $monitors.delete( monitor )
              Maadi::post_message( :Less, "Monitor #{monitor.type} (#{monitor.to_s}) has been removed")

              # If the monitor has been reset, then the Controller and the Manager need to be re-initialized
              $controller = nil
              $manager = nil
            end
          end
        when 'tasker'
          $taskers.each do |tasker|
            if ( tasker.type == value ) || ( tasker.instance_name == value )
              $taskers.delete( tasker )
              Maadi::post_message( :Less, "Tasker #{tasker.type} (#{tasker.to_s}) has been removed")

              # If the tasker has been reset, then the Controller and the Manager need to be re-initialized
              $controller = nil
              $manager = nil
            end
          end
        when 'scheduler'
          Maadi::post_message( :Less, "Scheduler #{$scheduler.type} (#{$scheduler.to_s}) has been removed")
          $scheduler = nil

          # If the Monitor has been reset, then the Controller and Manager needs to be re-initialized
          $controller = nil
          $manager = nil
        when 'application'
          $applications.each do |application|
            if ( application.type == value ) || ( application.instance_name == value )
              $applications.delete( application )
              Maadi::post_message( :Less, "Application #{application.type} (#{application.to_s}) has been removed")

              # Any of the Applications has been reset, then the Controller and Manager needs to be re-initialized
              $controller = nil
              $manager = nil
            end
          end
        when 'analyzer'
          $analyzers.each do |analyzer|
            if ( analyzer.type == value ) || ( analyzer.instance_name == value )
              $analyzers.delete( analyzer )
              Maadi::post_message( :Less, "Analyzer #{analyzer.type} (#{analyzer.to_s}) has been removed")

              # Any of the Analyzers have been reset, then the Manager needs to be re-initialized
              $manager = nil
            end
          end
        else
          Maadi::post_message(:Warn, "Incorrect usage, #{type} is an unrecognized option")
      end

      refresh_items( type )
    end
  end
end

