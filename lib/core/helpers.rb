# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : helpers.rb
#
# Summary: Some general helper functions to make life a little easier.

require_relative 'cli/globals'

module Maadi
  # post_message will display a message to standard out which includes a symbol for
  # its relative importance, a time stamp and the message.  They are tab deliminated.
  def self.post_message( type, message, level=1 )
    types = { :Warn => '[!]', :Info => '[*]', :More => '[+]', :Less => '[-]', :None => '   '}
    t = Time.now

    if level <= $verbosity
      puts "#{types[type]}\t#{t.strftime('%Y:%m:%d:%H:%M:%S')}\t#{message}"
    end
  end
end