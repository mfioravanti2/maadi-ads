# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : globals.rb
#
# Summary: Global variables for use with the CLI.

require_relative 'globals'

module Maadi
  module CLI
    def self.help(type = 'all')
      case type.downcase
        when 'set'
          puts 'set <type> <object> [<instance_name>]'
          puts ' load a custom object'
          puts '<type>          can be application, collector, expert, monitor, organizer, scheduler, or tasker'
          puts '<object>        can be any name returned by the results of list <type> command'
          puts '<instance_name> optional name to allow multiple objects of the same object type to'
          puts '                be individually specified. (OPTIONAL)'
          puts 'set default'
          puts ' load the default set of objects'
          puts 'set <type> option (<instance_name>) <option> <value>'
          puts ' set the unique options of an individual object'
          puts '<option>        the option to be changed, can be shown with the show <type> command'
          puts '<value>         the value of the option to be changed'
        when 'unset'
          puts 'unset <type>'
          puts ' removes a loaded item from the current configuration'
          puts '<type> can be application, collector, expert, monitor, organizer, scheduler, or tasker'
        when 'list'
          puts 'list <type>'
          puts ' list the custom modules available to load into the application'
          puts '<type> can be application, collector, expert, monitor, organizer, scheduler, or tasker'
        when 'show'
          puts 'show'
          puts ' display the current configuration (all custom objects)'
          puts ''
          puts 'show <type>'
          puts ' display the configurable options for an individual component'
          puts '<type> can be application, collector, expert, monitor, organizer, scheduler, or tasker'
        when 'save'
          puts 'save [filename]'
          puts ' saves the current configuration to a specified file, this is a safe save it'
          puts ' will NOT overwrite existing files or change the current configuration.'
          puts '[filename] is optional, if no name is specified an timestamped name will be used.'
        when 'load'
          puts 'load <filename>'
          puts ' load and execute the steps found in an existing Maadi configuration file.'
        when 'prep'
          puts 'prep'
          puts ' prepare all components for a test run'
        when 'start'
          puts 'start'
          puts ' start a test run'
        when 'exit'
          puts 'exit'
          puts ' quit the application'
        else
          puts 'help <command>'
          puts ' display help about a specific Maadi command'
          puts '<command> can be exit, list, load, prep, save, set, show, start, or unset'
      end
    end
  end
end

