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

      # return a procedure (Maadi::Procedure::Procedure) based on an id
      def procedure( id )
        return nil
      end

      # obtain a results (Maadi::Procedure::Results) based on an id
      def results( id )
        return nil
      end

      # obtain a list of status found within the results of repository
      # return (Array of String) each element represents a different status within the repository
      def statuses
        return Array.new
      end

      # obtain a list of applications found within the results of repository
      # return (Array of String) each element represents a different application within the repository
      def applications
        return Array.new
      end

      # obtain a list of status and their respective counts found within the repository
      # return (Array of Hashes) each hash contains :status is the status, :count is the count
      def status_counts
        return Array.new
      end

      # obtain a list of status and their respective counts for each application found within the repository
      # return (Array of Hashes) each hash contains :app is the application, :status is the status, :count is the count
      def status_counts_by_application
        return Array.new
      end

      # obtain a list of the procedures and their respective counts within the repository
      # return (Array of Hashes) each hash contains :id is the procedure id, :count is the count
      def procedure_counts
        return Array.new
      end

      # obtain a list of the procedures and their respective counts within the repository,
      # limited by a user specified status
      # status (String) specifying the status to limit the counts
      # return (Array of Hashes) each hash contains :id is the procedure id, :count is the count
      def procedures_by_status( status )
        return Array.new
      end

      # obtain a list of the steps and their respective counts within the repository
      # return (Array of Hashes) each hash contains :id is the step id, :count is the count
      def step_counts
        return Array.new
      end

      # obtain a list of the step and their respective counts within the repository,
      # limited by a user specified status
      # status (String) specifying the status to limit the counts
      # return (Array of Hashes) each hash contains :id is the step id, :count is the count
      def steps_by_status( status )
        return Array.new
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