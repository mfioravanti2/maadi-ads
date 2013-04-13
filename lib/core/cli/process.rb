# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : process.rb
# License: Creative Commons Attribution
#
# Summary: CLI major functions; process command, load/save profile
#          ALL CLI functionality is within the Maadi::CLI namespace

require_relative 'show'
require_relative 'set'
require_relative 'unset'
require_relative 'help'

module Maadi
  module CLI
    $logger = nil

    def self.save_profile( name )
      if File.exists?( name )
        post_message(:Warn, "#{name} already exists, please use another name")
      else
        File.open(name, 'w') do |f|
          f.puts "set runs #{$runs}"

          $collectors.each do |collector|
            f.puts "set collector #{collector.type} #{collector.instance_name}"
            collector.options.each do |option|
              f.puts "set collector option #{collector.instance_name} #{option} #{collector.get_option(option)}"
            end
          end

          if $expert != nil
            f.puts "set expert #{$expert.type} #{$expert.instance_name}"
            $expert.options.each do |option|
              f.puts "set expert option #{$expert.instance_name} #{option} #{$expert.get_option(option)}"
            end
          end

          f.puts "set organizer #{$organizer.type} #{$organizer.instance_name}" if $organizer != nil

          $monitors.each do |monitor|
            f.puts "set monitor #{monitor.type} #{monitor.instance_name}"
            monitor.options.each do |option|
              f.puts "set collector option #{monitor.instance_name} #{option} #{monitor.get_option(option)}"
            end
          end

          $applications.each do |application|
            f.puts "set application #{application.type} #{application.instance_name}"
            application.options.each do |option|
              f.puts "set collector option #{option} #{application.instance_name} #{application.get_option(option)}"
            end
          end

          $taskers.each do |tasker|
            f.puts "set tasker #{tasker.type} #{tasker.instance_name}"
            tasker.options.each do |option|
              f.puts "set tasker option #{tasker.instance_name} #{option} #{tasker.get_option(option)}"
            end
          end

          if $scheduler != nil
            f.puts "set scheduler #{$scheduler.type} #{$scheduler.instance_name}"
            $scheduler.options.each do |option|
              f.puts "set scheduler option #{$scheduler.instance_name} #{option} #{$scheduler.get_option(option)}"
            end
          end

          $controller.options.each do |option|
            f.puts "set controller option #{$controller.instance_name} #{option} #{$controller.get_option(option)}"
          end

          f.puts "set analyzer #{$analyzer.type} #{$analyzer.instance_name}" if $analyzer != nil
        end
        post_message(:Info, "#{name} saved")
      end
    end

    def self.load_profile( name )
      if File.exists?( name )
        profile = File.readlines( name )
        profile.each do |line|
          if line[0,1] != '#' && line.strip.length > 1
            commands = line.chomp.split(' ')
            process( commands )
          end
        end

        Maadi::post_message(:Info, "#{name} completed loading")
      else
        Maadi::post_message(:Warn, "#{name} does NOT exist")
      end
    end

    def self.process( commands )
      unless $logger
        t = Time.now
        logger_name = "Maadi-#{t.strftime('%Y%m%d%H%M%S')}.cli"
        $logger = File.open(logger_name, 'w')
      end

      if $logger
        $logger.puts "#{commands.join(' ')}"
      end

      case commands[0]
        when 'exit'
          if $manager != nil
            if $manager.is_prepared?
              $manager.teardown
            end
          end
          exit
        when 'help'
          if commands.length > 1
            help( commands[1] )
          else
            help('all')
          end
        when 'show'
          if commands.length > 1
            show_items( commands[1] )
          else
           show_config
          end
        when 'list'
          if commands.length > 1
            list_items( commands[1] )
          else
            Maadi::post_message(:Warn, 'Incorrect usage, try')
            Maadi::post_message(:Info, "\tlist (collector|expert|organizer|monitor|application|scheduler|analyzer)")
          end
        when 'set'
          # set has multiple options
          # usage #1 (create an object)
          # set <type> <object> (<instance_name>)
          #  this will use the factory to create an object and name it with instance
          #  object is optional, if nothing is specified, then the default object will be created.
          # usage #2 (set an object's options)
          # set <type> option (<instance_name>) <option> <value>
          if commands.length == 2
            if commands[1] == 'default'
              set_default
            else
              set_item( commands[1], 'default', 'none' )
            end
          elsif  commands.length == 3
            set_item( commands[1], commands[2], 'none' )
          elsif  commands.length == 4
            set_item( commands[1], commands[2], commands[3] )
          elsif commands.length > 4
            if commands[2] == 'option'
              if commands.length == 5
                set_option( commands[1], 'none', commands[3], commands[4] )
              elsif commands.length == 6
                set_option( commands[1], commands[3], commands[4], commands[5] )
              end
            end
          else
            Maadi::post_message(:Warn, 'Incorrect usage, try')
            Maadi::post_message(:Info, "\tset (collector|expert|organizer|monitor|application|scheduler|analyzer) [value]")
          end
        when 'unset'
          if commands.length > 2
            unset_item( commands[1], commands[2] )
          elsif commands.length > 1
            unset_item( commands[1] )
          else
            Maadi::post_message(:Warn, 'Incorrect usage, try')
            Maadi::post_message(:Info, "\tunset (collector|expert|organizer|monitor|application|scheduler|analyzer) [value]")
          end
        when 'prep'
          if $manager != nil
            $manager.prepare
          else
            Maadi::post_message(:Warn, "\tManager is not ready, use 'show' to determine what is not ready")
          end
        when 'start'
          if $manager != nil
            if $manager.is_prepared?
              $manager.start
            else
              Maadi::post_message(:Warn, "\tManager is not ready, use 'prep' to prepare the environment")
            end
          else
            Maadi::post_message(:Warn, "\tManager is not ready, use 'show' to determine what is not ready")
          end
        when 'report'
        when 'save'
          if commands.length > 1
            save_profile( commands[1] )
          else
            t = Time.now
            save_profile( "#{t.strftime('%Y%m%d%H%M%S')}.maadi" )
          end
        when 'load'
          if commands.length > 1
            load_profile( commands[1] )
          end
        else
          Maadi::post_message(:Warn, "Unknown command, #{commands[0]} is unrecognized")
      end
    end
  end
end

