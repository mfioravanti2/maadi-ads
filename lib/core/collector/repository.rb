# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : repository.rb
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
        Maadi::post_message(:More, "Repository (#{@type}:#{@instance_name}) is ready")
        super(false)
      end

      # teardown will remove all of the resources and services that were created specifically for this test.
      def teardown
        Maadi::post_message(:Less, "Repository (#{@type}:#{@instance_name}) is NO longer ready")
        super(false)
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

      # obtain a list of types found within the results of repository
      # return (Array of String) each element represents a different type within the repository
      def types
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

      # obtain a list of the procedure names and their respective counts within the repository
      # return (Array of Hashes) each hash contains :name is the procedure name, :count is the count
      def procedure_name_counts
        return Array.new
      end

      # obtain a list of the procedure names and their respective counts within the repository,
      # limited by a user specified status
      # status (String) specifying the status to limit the counts
      # return (Array of Hashes) each hash contains :name is the procedure name, :count is the count
      def procedure_names_by_status( status )
        return Array.new
      end

      # obtain a list of the procedures and their respective counts within the repository
      # return (Array of Hashes) each hash contains :id is the procedure id, :count is the count
      def procedure_id_counts
        return Array.new
      end

      # obtain a list of the procedure ids and their respective counts within the repository,
      # limited by a user specified status
      # status (String) specifying the status to limit the counts
      # return (Array of Hashes) each hash contains :id is the procedure id, :count is the count
      def procedure_ids_by_status( status )
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

      # obtain a list of the procedures which have status codes that do not match within the repository
      # return (Array of String) contains a list of procedure ids which do not match
      def procedure_ids_by_mismatch
        return Array.new
      end

      # obtain a list of the procedures which have resultant numeric values which differ by epsilon value
      # the comparison is performed horizontally, e.g. across the results (between applications)
      # type (String) data types to compare, should be items such as INTEGER, FLOAT, etc.
      #               TEXT should not be used with this function, procedure_ids_by_compare should be used.
      # epsilon (String) epsilon values to be used in the result comparison
      # return (Array of String) contains a list of procedure ids which are different
      def pids_from_delta_data_by_horizontal( type, epsilon )
        return Array.new
      end

      # obtain a list of the procedures which have resultant numeric values which differ by epsilon value
      # the comparison is performed vertically, e.g. within the same procedure (between steps)
      # type (String) data types to compare, should be items such as INTEGER, FLOAT, etc.
      #               TEXT should not be used with this function, procedure_ids_by_compare should be used.
      # epsilon (String) epsilon values to be used in the result comparison
      # relationship (String) type of comparison to perform.
      # return (Array of String) contains a list of procedure ids which are different
      def pids_from_delta_data_by_vertical( type, epsilon, relationship )
        return Array.new
      end

      # obtain a list of the procedures which have status codes that do not match within the repository
      # the comparison is performed horizontally, e.g. across the results (between applications)
      # type (String) data types to compare.
      # return (Array of String) contains a list of procedure ids which are different
      def pids_from_data_by_horizontal( type )
        return Array.new
      end

      # obtain a list of the procedures which have status codes that do not match within the repository
      # the comparison is performed vertically, e.g. within the same procedure (between steps)
      # type (String) data types to compare.
      # relationship (String) type of comparison to perform.
      # return (Array of String) contains a list of procedure ids which are different
      def pids_from_data_by_vertical( type, relationship )
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