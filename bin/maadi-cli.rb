# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : maadi-cli.rb
# License: Creative Commons Attribution
#
# Summary: This is the main Command Line Interface for the Maadi HiVAT program.

# include the required rubygems
require 'rubygems'

# include the required libraries
require_relative '../lib/core/cli/process'

module Maadi
  module CLI
    # load our default profile
    load_profile( 'default.maadi' )

    # main loop to capture commands from the user
    while true
      print 'maadi> '
      command = gets().chomp()
      commands = command.split(' ')
      process( commands )
    end
  end
end
