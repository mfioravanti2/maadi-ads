# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : globals.rb
#
# Summary: Global variables for use with the CLI.

require_relative '../helpers'

module Maadi
  module CLI
    $collectors = Array.new
    $applications = Array.new
    $expert = nil
    $organizer = nil
    $generator = nil
    $analyzer = nil
    $monitors = Array.new
    $taskers = Array.new
    $scheduler = nil
    $controller = nil
    $manager = nil
    $runs = 100
  end
end

