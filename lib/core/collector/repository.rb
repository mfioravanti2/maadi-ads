# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : repository.rb
# License: Creative Commons Attribution
#
# Summary: The collector is a component which is able to record messages,
#          procedures and results.  It is a data repository which may or may not
#          be queriable.  It could be implemented as a database or a simple log
#          file.

require_relative 'collector'

module Maadi
  module Collector
    class Repository < Collector
      # type (String) is a convenient human readable label.
      def initialize(type)
        super(type)
        @readable = true
      end

      # prepare the repository;
      # if it is a database; connect to the database, validate the schema
      # if it is a log file; open the file for write only/append
      def prepare
        Maadi::post_message(:More, "Repository (#{@type}) is ready")
        super
      end

      # teardown will remove all of the resources and services that were created specifically for this test.
      def teardown
        Maadi::post_message(:Less, "Repository (#{@type}) is NO longer ready")
        super
      end

      def self.is_repository?( repository )
        if repository != nil
          if repository.is_a?( Maadi::Collector::Repository )
            return true
          end
        end

        return false
      end
    end
  end
end