# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : mysql.rb
#
# Summary: This is a MySQL DBMS Application interface.
# Examples/tutorial for using the mysql2 gem can be found here:
#          https://github.com/brianmario/mysql2
#
# Note: Ensure that the account has been created on the remote system run
# the following commands locally on the MySQL server;
#
# GRANT ALL ON *.* TO 'user'@'client ip' IDENTIFIED BY 'password';
# FLUSH PRIVILEGES;
#
# user is the account name to allow remote access.
# client ip is the IP address of the client system (not the server)
# password is the password used to identify the account.
#
# Simple verification with; SELECT Host,User FROM mysql.user;
#
# Also make sure that MySQL is listening on an available interface
# and still not configured for $bind_address = 127.0.0.1

require 'rubygems'
require 'mysql2'

gem 'mysql2'

require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Application
    class MySQL < Application

      def initialize
        super('MySQL')

        @options['HOSTNAME'] = 'localhost'
        @options['USERNAME'] = 'hivat'
        @options['PASSWORD'] = 'hivat123hivat123'
        @options['DATABASE'] = 'HiVAT'

        @notes['HOSTNAME'] = 'FQDN, IP address, or localhost'
        @notes['USERNAME'] = 'Account for accessing the DBMS'
        @notes['PASSWORD'] = "Corresponding account's password"
        @notes['DATABASE'] = 'Database in the DBMS to use'

        @db = nil
      end

      def supported_domains
        return %w(SQL)
      end

      def prepare
        begin
          @db = ::Mysql2::Client.new(:host => @options['HOSTNAME'], :username => @options['USERNAME'], :password => @options['PASSWORD'], :database => @options['DATABASE'])

        rescue => e
          #  Can't connect to MySQL server on '192.168.187.150' (10060)
          #   means that the remote server cannot be reached; is the server up or is there a firewall in the way?
          #  Host 'nn.nn.nn.nn' is not allowed to connect to this MySQL server (Mysql2::Error)
          #   means that the client does not have remote access privileges
          #  Access denied for user 'database_account'@'nn.nn.nn.nn' (using password: YES) (Mysql2::Error)
          #   means that the username or password is incorrect
          #  Unknown database 'database_name' (Mysql2::Error)
          #   means that the database is spelled wrong, not present or otherwise in disposed of.
          #puts "#{e.message}"
          Maadi::post_message(:Warn, "Application (#{@type}:#{@instance_name}) was unable to connect (#{e.message}).")
          @db = nil
        end

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
              when 'CREATE-DATABASE'
                return true
              when 'DROP-TABLE'
                return true
              when 'DROP-DATABASE'
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
                    rs = @db.query( sql_cmd )

                    case step.look_for
                      when 'NORECORD'
                      when 'CHANGES'
                        results.add_result( Maadi::Procedure::Result.new( step, @db.affected_rows, 'TEXT', 'SUCCESS' ))
                      when 'COMPLETED'
                        results.add_result( Maadi::Procedure::Result.new( step, '', 'TEXT', 'SUCCESS' ))
                      else
                        results.add_result( Maadi::Procedure::Result.new( step, '', 'TEXT', 'UNKNOWN' ))
                    end
                  rescue => e
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