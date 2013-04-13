# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : Example.rb
# License: Creative Commons Attribution
#
# Summary: This is a SQLite3 DBMS Application interface.

require 'rubygems'
require 'sqlite3'

gem 'sqlite3'

require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Application
    class SQLite3 < Application

      def initialize
        super('SQLite3')

        t = Time.now
        @options['DATABASE'] = "HiVAT-#{t.strftime('%Y%m%d%H%M%S')}.db"

        @notes['DATABASE'] = 'Name of the SQLite3 database'

        @db = nil
      end

      def supported_domains
        return %w(SQL)
      end

      def prepare
        # open the database.
        if File.exist?(@options['DATABASE'])
          @db = ::SQLite3::Database.open(@options['DATABASE'])
        else
          @db = ::SQLite3::Database.new(@options['DATABASE'])
        end
        @db.results_as_hash = true

        if @db != nil
          super
        end
      end

      def supports_step?( step )
        if step != nil
          if step.is_a?( ::Maadi::Procedure::Step )
            case step.id
              when 'CREATE-TABLE'
                return true
              when 'DROP-TABLE'
                return true
              when 'INSERT-SPECIFIED'
                return true
              when 'INSERT-IMPLICIT'
                return true
              when 'INSERT-MULTIROW'
                return true
              when 'SELECT'
                return true
              when 'UPDATE'
                return true
              when 'DELETE'
                return true
              else
            end

          end
        end

        return false
      end

      def execute( test_id, procedure )
        results = Maadi::Procedure::Results.new( test_id.to_i, 0, "#{@type}:#{@instance_name}", nil )

        if @db != nil
          if procedure.is_a?( ::Maadi::Procedure::Procedure )
            results.proc_id = procedure.id

            procedure.steps.each do |step|
              if step.target == execution_target
                sql_cmd = step.execute
                if supports_step?( step )
                  begin
                    rs = @db.execute( sql_cmd )

                    case step.look_for
                      when 'NORECORD'
                      when 'CHANGES'
                        results.add_result( Maadi::Procedure::Result.new( step, @db.changes, 'INTEGER', 'SUCCESS' ))
                      when 'COMPLETED'
                        results.add_result( Maadi::Procedure::Result.new( step, '', 'TEXT', 'SUCCESS' ))
                      else
                        results.add_result( Maadi::Procedure::Result.new( step, '', 'TEXT', 'UNKNOWN' ))
                    end
                  rescue ::SQLite3::Exception => e
                    Maadi::post_message(:Warn, "Application (#{@type}:#{@instance_name}) encountered an error (#{e.message}).")
                    results.add_result( Maadi::Procedure::Result.new( step, e.message, 'TEXT', 'EXCEPTION' ))
                  end
                else
                  Maadi::post_message(:Warn, "Application (#{@type}:#{@instance_name}) encountered an unsupported step (#{procedure.id}, #{step.id}).")
                end
              end
            end
          end
        end

        return results
      end

      def teardown
        if @db != nil
          @db.close
        end

        super
      end
    end
  end
end