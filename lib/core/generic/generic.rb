# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : generic.rb
# License: Creative Commons Attribution
#
# Summary: This is a general interface class which allows all of the
#          Maadi objects to interact with specific behaviors and functionality.
#          Each object has a type (or human readable label) and should allow
#          itself to be prepared, determine if it is ready, and teardown.

module Maadi
  module Generic
    class Generic
      # limited attributes are available for use.
      # type (string) is a convenient human readable label.
      attr_accessor :type, :instance_name

      # type (String) is a convenient human readable label.
      def initialize(type)
        @type = type
        @ready = false
        @instance_name = "#{@type}#{1 + rand(20)}"
        @options = Hash.new
        @notes = Hash.new
      end

      def to_s
        return "#{@type}<#{@instance_name}>"
      end

      # determine if the generic object is ready to process log requests
      # return (bool) true if the object is ready
      def is_ready?
        return @ready
      end

      def prepare
        @ready = true
      end

      # teardown will remove all of the resources and services that were created specifically for this test.
      def teardown
        @ready = false
      end

      def options
        return @options.keys
      end

      def get_option( option )
        if @options.keys.include?( option )
          return @options[option]
        end

        return ''
      end

      def get_notes( option )
        if @options.keys.include?( option )
          return @notes[option]
        end

        return ''
      end

      def set_option( option, value )
       if @options.keys.include?( option )
         @options[option] = value
         @ready = false
       end
      end

      def are_options_valid?
        return true
      end

      def time_stamp
        t = Time.now
        return "#{t.strftime('%Y%m%d%H%M%S')}"
      end

      def self.is_generic?( generic )
        if generic != nil
          if generic.is_a?( Maadi::Generic::Generic )
            return true
          end
        end

        return false
      end
     end
  end
end