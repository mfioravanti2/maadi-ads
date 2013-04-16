# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : show.rb
# License: Creative Commons Attribution
#
# Summary: CLI commands to display the current configuration and list available options

require_relative 'globals'
require_relative '../../custom/factories'

module Maadi
  module CLI
    def self.item_status( type )
      case type.downcase
        when 'collector'
          # check to see if any Applications have been instantiated.
          return ( $collectors.length > 0 ) ? ( 'using ' + $collectors.join(', ') ) : '<unspecified collectors(s)>'
        when 'expert'
          # check to see if an Expert has been instantiated.
          return ( $expert != nil ) ? ( 'using ' + $expert.to_s    ) : '<unspecified expert>'
        when 'organizer'
          # check to see if an Organizer has been instantiated.
          return ( $organizer  != nil ) ? ( 'using ' + $organizer.to_s ) : '<unspecified organizer>'
        when 'generator'
          # check to see if the Generator preconditions have been met.
          # (i.e. all of the necessary objects are available to instantiate an Generator object)
          if $generator == nil
            needs = Array.new
            if $expert == nil
              needs.push 'Expert'
            end
            if $organizer == nil
              needs.push 'Organizer'
            end

            return "Need #{needs.sort.join(', ')}"
          else
            return 'available'
          end
        when 'monitor'
          # check to see if any Applications have been instantiated.
          return ( $monitors.length > 0 ) ? ( 'using ' + $monitors.join(', ') ) : '<unspecified monitor(s)>'
        when 'tasker'
          # check to see if any Applications have been instantiated.
          return ( $taskers.length > 0 ) ? ( 'using ' + $taskers.join(', ') ) : '<unspecified tasker(s)>'
        when 'scheduler'
          # check to see if an Scheduler has been instantiated.
          return ( $scheduler  != nil ) ? ( 'using ' + $scheduler.to_s ) : '<unspecified scheduler>'
        when 'application'
          # check to see if any Applications have been instantiated.
          return ( $applications.length > 0 ) ? ( 'using ' + $applications.join(', ') ) : '<unspecified application(s)>'
        when 'controller'
          # check to see if the Controller preconditions have been met.
          # (i.e. all of the necessary objects are available to instantiate an Controller object)
          if $controller == nil
            needs = Array.new
            if $scheduler == nil
              needs.push 'Scheduler'
            end
            if $generator == nil
              needs.push 'Generator'
            end
            if $collectors.length == 0
              needs.push 'Collector(s)'
            end
            if $applications.length == 0
              needs.push 'Application(s)'
            end

            return "Need #{needs.sort.join(', ')}"
          else
            return 'available'
          end
        when 'analyzer'
          # check to see if an Analyzer has been instantiated.
          return ( $analyzer != nil ) ? ( 'using ' + $analyzer.to_s ) : '<unspecified analyzer>'
        when 'manager'
          # check to see if the Manager preconditions have been met.
          # (i.e. all of the necessary objects are available to instantiate an Manager object)
          if $manager == nil
            needs = Array.new
            if $collectors.length == 0
              needs.push 'Collector(s)'
            end
            if $controller == nil
              needs.push 'Controller'
            end
            if $analyzer == nil
              needs.push 'Analyzer'
            end

            return "Need #{needs.sort.join(', ')}"
          else
            return 'available'
          end
        else
          return ''
      end
    end

    def self.show_options( type, item, options )
      if options.length > 0
        Maadi::post_message(:Info, "#{type} (#{item.to_s}) Current Options")

        printf( "%15s %25s %s\n", '    Option    ', 'Value    ', 'Notes')
        printf( "%15s %25s %s\n", '==============', '=============', '=============')
        options.each do |option|
          printf( "%15s %25s %s\n", option, item.get_option(option), item.get_notes(option) )
        end
        puts
      end
    end

    def self.show_items( type )
      case type.downcase
        when 'collector'
          $collectors.each do |collector|
            show_options( 'Collector', collector, collector.options )
          end
        when 'controller'
          if $controller != nil
           show_options( 'Controller', $controller, $controller.options )
          end
        when 'expert'
          if $expert != nil
            show_options( 'Expert', $expert, $expert.options )
          end
        when 'organizer'
          if $organizer != nil
            show_options( 'Organizer', $organizer, $organizer.options )
          end
        when 'monitor'
          $monitors.each do |monitor|
            show_options( 'Monitor', monitor, monitor.options )
          end
        when 'scheduler'
          if $scheduler != nil
            show_options( 'Scheduler', $scheduler, $scheduler.options )
          end
        when 'application'
          $applications.each do |application|
            show_options( 'Application', application, application.options )
          end
        when 'tasker'
          $taskers.each do |tasker|
            show_options( 'Tasker', tasker, tasker.options )
          end
        when 'analyzer'
          if $analyzer != nil
            show_options( 'Analyzer', $analyzer, $analyzer.options )
          end
        when 'manager'
          if $analyzer != nil
            show_options( 'Manager', $manager, $manager.options )
          end
        else
          Maadi::post_message(:Warn, "Incorrect usage, #{type} is an unrecognized option")
      end
    end

    def self.show_config
      Maadi::post_message(:Info, 'Current Configuration')
      printf "[*]\tRuns           : " + $runs.to_s + "\n"
      printf "[*]\tCollector(s)   : " + item_status('collector') + "\n"
      printf "[*]\tExpert         : " + item_status('expert') + "\n"
      printf "[*]\tOrganizer      : " + item_status('organizer') + "\n"
      printf "[*]\tGenerator      : " + item_status('generator') + "\n"
      printf "[*]\tMonitor(s)     : " + item_status('monitor') + "\n"
      printf "[*]\tScheduler      : " + item_status('scheduler') + "\n"
      printf "[*]\tApplication(s) : " + item_status('application') + "\n"
      printf "[*]\tTasker(s)      : " + item_status('tasker') + "\n"
      printf "[*]\tController     : " + item_status('controller') + "\n"
      printf "[*]\tAnalyzer       : " + item_status('analyzer') + "\n"
      printf "[*]\tManager        : " + item_status('manager') + "\n"
    end

    def self.list_items( type )
      options = Array.new

      case type.downcase
        when 'collector'
          options = Maadi::Collector::Collector.choices()
        when 'expert'
          options = Maadi::Expert::Expert.choices()
        when 'organizer'
          options = Maadi::Organizer::Organizer.choices()
        when 'monitor'
          options = Maadi::Monitor::Monitor.choices()
        when 'tasker'
          options = Maadi::Tasker::Tasker.choices()
        when 'scheduler'
          options = Maadi::Scheduler::Scheduler.choices()
        when 'application'
          options = Maadi::Application::Application.choices()
        when 'analyzer'
          options = Maadi::Analyzer::Analyzer.choices()
        else
          Maadi::post_message(:Warn, "Incorrect usage, #{type} is an unrecognized option")
      end

      if options.length > 0
        Maadi::post_message(:Info, "Possible options: #{options.join(', ')}")
      else
        Maadi::post_message(:Warn, "Unable to find options for #{type}")
      end
    end
  end
end

