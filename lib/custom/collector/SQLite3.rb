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
    class SQLite3 < Collector

      def initialize
        super('SQLite3')
        @readable = true

        @db = nil

        t = Time.now
        @options['DATABASE'] = "Maadi-#{t.strftime('%Y%m%d%H%M%S')}.db"

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
                         rApp varchar(255))
                      )

          @db.execute( tbl_def )

          tbl_def = %q( CREATE TABLE IF NOT EXISTS tblResultData (
                         dID integer primary key,
                         rID integer,
                         dStep varchar(255),
                         dStatus varchar(255),
                         dType varchar(255),
                         dData TEXT)
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
            Maadi::post_message(:Warn, "Collector (#{@type}:#{@instance_name}) encountered an error (#{e.message}).")
          end
        end
      end

      # log a procedure to the database
      # procedure (Procedure) procedure to be recorded in the database
      def log_procedure( procedure )
        prId = -1

        if procedure != nil
          if procedure.is_a?( Maadi::Procedure::Procedure )
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
                Maadi::post_message(:Warn, "Collector (#{@type}:#{@instance_name}) encountered an error (#{e.message}).")
              end

              if is_ok && prId != -1
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
                    Maadi::post_message(:Warn, "Collector (#{@type}:#{@instance_name}) encountered an error (#{e.message}).")
                  end

                  if is_ok && stId != -1
                    is_ok = false

                    # attempt to insert the step's parameters into the tblParameters, since the tblSteps INSERT was successful
                    # CREATE TABLE IF NOT EXISTS tblParameters ( pID integer primary key, sID integer, pLabel varchar(255), pValue varchar(255), pConstraint varchar(255))

                    step.parameters.each do |parameter|
                      is_ok = false

                      begin
                        stm = @db.prepare( 'INSERT INTO tblParameters (sID, pLabel, pValue, pConstraint) VALUES (?, ?, ?, ?)')
                        stm.bind_params( stId, parameter.label, parameter.value.to_s, parameter.constraint.to_s )
                        rs = stm.execute
                        stm.close
                        is_ok = true
                      rescue ::SQLite3::Exception => e
                        Maadi::post_message(:Warn, "Collector (#{@type}:#{@instance_name}) encountered an error (#{e.message}).")
                      end

                      break if !is_ok
                    end
                  end

                  # if we have encountered any INSERT errors, do not attempt to process any more INSERTs
                  break if !is_ok
                end
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
        if (application != nil) && (procedure != nil) && (results != nil)
          if (application.is_a?(Maadi::Application::Application)) && ( procedure.is_a?( Maadi::Procedure::Procedure ) ) && ( results.is_a?(Maadi::Procedure::Results) )
            t = Time.now
            log_time = "#{t.strftime('%Y/%m/%d %H:%M:%S')}"

            if @db != nil
              is_ok = false
              rId = -1

              begin
                stm = @db.prepare( 'INSERT INTO tblResults (rTestId, rTime, rApp, rProc) VALUES (?, ?, ?, ?)')
                stm.bind_params( procedure.key_id, log_time, application.to_s, procedure.to_s )
                rs = stm.execute
                rId = @db.last_insert_row_id.to_s
                stm.close
                is_ok = true
              rescue ::SQLite3::Exception => e
                Maadi::post_message(:Warn, "Collector (#{@type}:#{@instance_name}) encountered an error (#{e.message}).")
              end

              if is_ok && rId != -1
                # attempt to insert the procedure's steps into the tblSteps, since the tblProcedure INSERT was successful
                # CREATE TABLE IF NOT EXISTS tblResultData ( dID integer primary key, rID integer, dStep varchar(255), dStatus varchar(255), dType varchar(255), dData TEXT)

                results.results.each do |result|
                  is_ok = false
                  rdId = -1

                  begin
                    stm = @db.prepare( 'INSERT INTO tblResultData (rID, dStep, dStatus, dType, dData) VALUES (?, ?, ?, ?, ?)' )
                    stm.bind_params( rId, result.step, result.status, result.type, result.data.to_s )
                    rs = stm.execute
                    rdId = @db.last_insert_row_id.to_s
                    stm.close
                    is_ok = true
                  rescue ::SQLite3::Exception => e
                    Maadi::post_message(:Warn, "Collector (#{@type}:#{@instance_name}) encountered an error (#{e.message}).")
                  end

                  # if we have encountered any INSERT errors, do not attempt to process any more INSERTs
                  break if !is_ok
                end
              end
            end
          end
        end
      end

      # teardown will remove all of the resources and services that were created specifically for this test.
      def teardown
        @db.close
        super
      end
    end
  end
end