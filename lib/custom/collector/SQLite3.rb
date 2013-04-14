# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : LogFile.rb
# License: Creative Commons Attribution
#
# Summary: This is an Database (SQLite3) version of a Collector

require 'rubygems'
require 'sqlite3'

gem 'sqlite3'

require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Collector
    class SQLite3 < Repository

      def initialize
        super('SQLite3')
        @readable = true

        @db = nil

        @options['DATABASE'] = "Maadi-#{time_stamp}.db"

        @notes['DATABASE'] = 'Name of the SQLite3 database'
      end

      # prepare the collector;
      # if it is a database; connect to the database, validate the schema
      # if it is a log file; open the file for write only/append
      def prepare
        super

        # open the database.
        if File.exist?(@options['DATABASE'])
          @db = ::SQLite3::Database.open(@options['DATABASE'])
        else
          @db = ::SQLite3::Database.new(@options['DATABASE'])
        end
        @db.results_as_hash = true

        tables = @db.execute('SELECT name FROM sqlite_master WHERE type="table" AND name="tblMessages" ORDER BY name')
        if tables.length == 0
          tbl_def = %q( CREATE TABLE IF NOT EXISTS tblMessages (
                         mID integer primary key,
                         mStatus char(5),
                         mTime datetime,
                         mText varchar(255))
                      )

          @db.execute( tbl_def )
        end

        tables = @db.execute('SELECT name FROM sqlite_master WHERE type="table" AND name="tblOptions" ORDER BY name')
        if tables.length == 0
          tbl_def = %q( CREATE TABLE IF NOT EXISTS tblOptions (
                         oID integer primary key,
                         oType varchar(255),
                         oInstance varchar(255),
                         oOption varchar(255),
                         oValue TEXT)
                      )

          @db.execute( tbl_def )
        end

        tables = @db.execute('SELECT name FROM sqlite_master WHERE type="table" AND name="tblProcedures" ORDER BY name')
        if tables.length == 0
          tbl_def = %q( CREATE TABLE IF NOT EXISTS tblProcedures (
                         pID integer primary key,
                         pTime datetime,
                         pProc varchar(255))
                      )

          @db.execute( tbl_def )

          tbl_def = %q( CREATE TABLE IF NOT EXISTS tblSteps (
                         sID integer primary key,
                         pID integer,
                         sLabel varchar(255),
                         sCommand TEXT,
                         sFinal TEXT)
                      )

          @db.execute( tbl_def )

          tbl_def = %q( CREATE TABLE IF NOT EXISTS tblParameters (
                         pID integer primary key,
                         sID integer,
                         pLabel varchar(255),
                         pValue varchar(255),
                         pConstraint varchar(255))
                      )

          @db.execute( tbl_def )
        end

        tables = @db.execute('SELECT name FROM sqlite_master WHERE type="table" AND name="tblResults" ORDER BY name')
        if tables.length == 0
          tbl_def = %q( CREATE TABLE IF NOT EXISTS tblResults (
                         rID integer primary key,
                         rTime datetime,
                         rTestId integer,
                         rProc varchar(255),
                         rProcId integer,
                         rApp varchar(255))
                      )

          @db.execute( tbl_def )

          tbl_def = %q( CREATE TABLE IF NOT EXISTS tblResultData (
                         dID integer primary key,
                         rID integer,
                         dStep varchar(255),
                         dStepId integer,
                         dStatus varchar(255),
                         dType varchar(255),
                         dData TEXT)
                      )

          @db.execute( tbl_def )
        end

        tables = @db.execute('SELECT name FROM sqlite_master WHERE type="view" AND name="qryResults" ORDER BY name')
        if tables.length == 0
          tbl_def = %q( CREATE VIEW IF NOT EXISTS qryResults AS
                         SELECT R.rTestId As qTestId, R.rProc As qProc, R.rProcId As qProcId, R.rApp As qApp,
                                D.dStep As qStep, D.dStepId As qStepId, D.dStatus As qStatus, D.dData As qData
                         FROM tblResults As R, tblResultData As D
                         WHERE D.rID = R.rID
                      )

          @db.execute( tbl_def )
        end
      end

      # log a message to the database
      # message (String) text message to be recorded in the database
      # return N/A
      def log_message( level, message )
        t = Time.now
        log_time = "#{t.strftime('%Y/%m/%d %H:%M:%S')}"

        if @db != nil
          begin
            stm = @db.prepare( 'INSERT INTO tblMessages (mStatus, mTime, mText) VALUES (?, ?, ?)' )
            stm.bind_params(level_text(level), log_time, message)
            rs = stm.execute
            mId = @db.last_insert_row_id.to_s
            stm.close
          rescue ::SQLite3::Exception => e
            Maadi::post_message(:Warn, "Repository (#{@type}:#{@instance_name}) encountered an error (#{e.message}).")
          end
        end
      end

      # log all of the options from a Maadi::Generic::Generic object
      # generic (Generic) object to have all of it's options recorded in the database
      # return N/A
      def log_options( generic )
        if Maadi::Generic::Generic::is_generic?( generic )
          options = generic.options
          if options.length > 0
            if @db != nil
              options.each do |option|
                begin
                  # CREATE TABLE IF NOT EXISTS tblOptions ( oID integer primary key, oType varchar(255), oInstance varchar(255), oOption varchar(255), oValue TEXT)
                  stm = @db.prepare( 'INSERT INTO tblOptions (oType, oInstance, oOption, oValue) VALUES (?, ?, ?, ?)' )
                  stm.bind_params(generic.type, generic.instance_name, option, generic.get_option(option))
                  rs = stm.execute
                  oId = @db.last_insert_row_id.to_s
                  stm.close
                rescue ::SQLite3::Exception => e
                  Maadi::post_message(:Warn, "Repository (#{@type}:#{@instance_name}) encountered an error (#{e.message}).")
                end
              end
            end
          end
        end
      end

      # log a procedure to the database
      # procedure (Procedure) procedure to be recorded in the database
      def log_procedure( procedure )
        prId = -1

        if Maadi::Procedure::Procedure::is_procedure?( procedure )
          t = Time.now
          log_time = "#{t.strftime('%Y/%m/%d %H:%M:%S')}"

          if @db != nil
            is_ok = false

            begin
              stm = @db.prepare( 'INSERT INTO tblProcedures (pTime, pProc) VALUES (?, ?)')
              stm.bind_params( log_time, procedure.to_s )
              rs = stm.execute
              prId = @db.last_insert_row_id.to_s
              stm.close
              is_ok = true
            rescue ::SQLite3::Exception => e
              Maadi::post_message(:Warn, "Repository (#{@type}:#{@instance_name}) encountered an INSERT Procedure error (#{e.message}).")
            end

            if is_ok && prId != -1
              if procedure.key_id == -1
                procedure.key_id = prId
              end

              # attempt to insert the procedure's steps into the tblSteps, since the tblProcedure INSERT was successful
              # CREATE TABLE tblSteps ( sID integer primary key, pID integer, sLabel varchar(255), sCommand TEXT, sFinal TEXT)

              procedure.steps.each do |step|
                is_ok = false
                stId = -1

                begin
                  stm = @db.prepare( 'INSERT INTO tblSteps (pID, sLabel, sCommand, sFinal) VALUES (?, ?, ?, ?)')
                  stm.bind_params( prId, step.id.to_s, step.command, step.execute )
                  rs = stm.execute
                  stId = @db.last_insert_row_id.to_s
                  stm.close
                  is_ok = true
                rescue ::SQLite3::Exception => e
                  Maadi::post_message(:Warn, "Repository (#{@type}:#{@instance_name}) encountered an INSERT Step error (#{e.message}).")
                end

                if is_ok && stId != -1
                  if step.key_id == -1
                    step.key_id = stId
                  end

                  is_ok = false

                  # attempt to insert the step's parameters into the tblParameters, since the tblSteps INSERT was successful
                  # CREATE TABLE IF NOT EXISTS tblParameters ( pID integer primary key, sID integer, pLabel varchar(255), pValue varchar(255), pConstraint varchar(255))

                  step.parameters.each do |parameter|
                    is_ok = false

                    begin
                      stm = @db.prepare( 'INSERT INTO tblParameters (sID, pLabel, pValue, pConstraint) VALUES (?, ?, ?, ?)')
                      stm.bind_params( stId, parameter.label, parameter.value.to_s, parameter.constraint.to_s )
                      rs = stm.execute
                      paId = @db.last_insert_row_id.to_s
                      stm.close
                      is_ok = true
                    rescue ::SQLite3::Exception => e
                      Maadi::post_message(:Warn, "Repository (#{@type}:#{@instance_name}) encountered an INSERT Parameter error (#{e.message}).")
                    end

                    break if !is_ok

                    if parameter.key_id == -1
                      parameter.key_id = paId
                    end
                  end
                end

                # if we have encountered any INSERT errors, do not attempt to process any more INSERTs
                break if !is_ok
              end
            end
          end
        end
      end

      # log the results of a test procedure that was executed
      # application (Application) application that the test procedure was executed against
      # procedure (Procedure) test procedure that was executed
      # results (Results) test results from executing the procedure against the application under test
      def log_results( application, procedure, results )
        if Maadi::Application::Application::is_application?( application ) and Maadi::Procedure::Procedure::is_procedure?( procedure ) and Maadi::Procedure::Results::is_results?( results )
          t = Time.now
          log_time = "#{t.strftime('%Y/%m/%d %H:%M:%S')}"

          if @db != nil
            is_ok = false
            rId = -1

            begin
              stm = @db.prepare( 'INSERT INTO tblResults (rTestId, rTime, rApp, rProc, rProcId) VALUES (?, ?, ?, ?, ?)')
              stm.bind_params( procedure.key_id, log_time, application.to_s, procedure.to_s, procedure.key_id )
              rs = stm.execute
              rId = @db.last_insert_row_id.to_s
              stm.close
              is_ok = true
            rescue ::SQLite3::Exception => e
              Maadi::post_message(:Warn, "Repository (#{@type}:#{@instance_name}) encountered an INSERT Results error (#{e.message}).")
            end

            if is_ok && rId != -1
              if results.key_id == -1
                results.key_id == rId
              end
              # attempt to insert the procedure's steps into the tblSteps, since the tblProcedure INSERT was successful
              # CREATE TABLE IF NOT EXISTS tblResultData ( dID integer primary key, rID integer, dStep varchar(255), dStatus varchar(255), dType varchar(255), dData TEXT)

              results.results.each do |result|
                is_ok = false
                rdId = -1

                begin
                  stm = @db.prepare( 'INSERT INTO tblResultData (rID, dStep, dStepId, dStatus, dType, dData) VALUES (?, ?, ?, ?, ?, ?)' )
                  stm.bind_params( rId, result.step_name, result.step_key, result.status, result.type, result.data.to_s )
                  rs = stm.execute
                  rdId = @db.last_insert_row_id.to_s
                  stm.close
                  is_ok = true
                rescue ::SQLite3::Exception => e
                  Maadi::post_message(:Warn, "Repository (#{@type}:#{@instance_name}) encountered an INSERT Result error (#{e.message}).")
                end

                # if we have encountered any INSERT errors, do not attempt to process any more INSERTs
                break if !is_ok

                if result.key_id == -1
                  result.key_id = rdId
                end
              end
            end
          end
        end
      end

      # return a procedure (Maadi::Procedure::Procedure) based on an id
      def procedure( id )
        if @db != nil

        end

        return nil
      end

      # obtain a results (Maadi::Procedure::Results) based on an id
      def results( id )
        if @db != nil

        end

        return nil
      end

      # obtain a list of status found within the results of repository
      # return (Array of String) each element represents a different status within the repository
      def statuses
        list = Array.new

        if @db != nil
          is_ok = false

          begin
            stm = @db.prepare( 'SELECT qStatus FROM qryResults GROUP BY qStatus ORDER BY qStatus')
            rs = stm.execute

            rs.each do |row|
              list.push row['qStatus']
            end

            stm.close
            is_ok = true
          rescue ::SQLite3::Exception => e
            Maadi::post_message(:Warn, "Repository (#{@type}:#{@instance_name}) encountered an SELECT statuses error (#{e.message}).")
          end
        end

        return list
      end

      # obtain a list of applications found within the results of repository
      # return (Array of String) each element represents a different application within the repository
      def applications
        list = Array.new

        if @db != nil
          is_ok = false

          begin
            stm = @db.prepare( 'SELECT qApp FROM qryResults GROUP BY qApp ORDER BY qApp')
            rs = stm.execute

            rs.each do |row|
              list.push row['qApp']
            end

            stm.close
            is_ok = true
          rescue ::SQLite3::Exception => e
            Maadi::post_message(:Warn, "Repository (#{@type}:#{@instance_name}) encountered an SELECT applications error (#{e.message}).")
          end
        end

        return list
      end

      # obtain a list of status and their respective counts found within the repository
      # return (Array of Hashes) each hash contains :status is the status, :count is the count
      def status_counts
        counts = Array.new

        if @db != nil

        end

        return counts
      end

      # obtain a list of status and their respective counts for each application found within the repository
      # return (Array of Hashes) each hash contains :app is the application, :status is the status, :count is the count
      def status_counts_by_application
        counts = Array.new

        if @db != nil

        end

        return counts
      end

      # obtain a list of the procedures and their respective counts within the repository
      # return (Array of Hashes) each hash contains :id is the procedure id, :count is the count
      def procedure_counts
        counts = Array.new

        if @db != nil

        end

        return counts
      end

      # obtain a list of the procedures and their respective counts within the repository,
      # limited by a user specified status
      # status (String) specifying the status to limit the counts
      # return (Array of Hashes) each hash contains :id is the procedure id, :count is the count
      def procedures_by_status( status )
        procedures = Array.new

        if @db != nil

        end

        return procedures
      end

      # obtain a list of the steps and their respective counts within the repository
      # return (Array of Hashes) each hash contains :id is the step id, :count is the count
      def step_counts
        steps = Array.new

        if @db != nil

        end

        return steps
      end

      # obtain a list of the step and their respective counts within the repository,
      # limited by a user specified status
      # status (String) specifying the status to limit the counts
      # return (Array of Hashes) each hash contains :id is the step id, :count is the count
      def steps_by_status( status )
        steps = Array.new

        if @db != nil

        end

        return steps
      end

      # teardown will remove all of the resources and services that were created specifically for this test.
      def teardown
        @db.close
        super
      end
    end
  end
end