# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : Example.rb
# License: Creative Commons Attribution
#
# Summary: This is a Structure Query Language Expert which can be use
#          to build and test for the ability to process SQL statements.

require_relative 'factory'
require_relative '../../core/helpers'
require_relative '../procedure/ConstraintConstant'
require_relative '../procedure/ConstraintSingleWord'
require_relative '../procedure/ConstraintSingleString'
require_relative '../procedure/ConstraintPickList'
require_relative '../procedure/ConstraintMultiPickList'
require_relative '../procedure/ConstraintMultiWord'
require_relative '../procedure/ConstraintRangedInteger'

module Maadi
  module Expert
    class SQL < Expert
      # default Expert constructor
      def initialize
        super('SQL')

        @tests = Array.new
        @active = 'HiVAT'
        @database = Hash.new
        add_database( @active )

        @options['MODELS'] = 'SINGLE'
        @options['DBASE_MINLEN'] = '5'
        @options['DBASE_MAXLEN'] = '25'
        @options['TABLE_MAXCNT'] = '-1'
        @options['TABLE_MINLEN'] = '5'
        @options['TABLE_MAXLEN'] = '25'
        @options['COLUMN_MAXCNT'] = '25'
        @options['COLUMN_MINLEN'] = '5'
        @options['COLUMN_MAXLEN'] = '25'

        @options['CREATE_RATIO'] = 1
        @options['INSERT_RATIO'] = 1
        @options['SELECT_RATIO'] = 1
        @options['UPDATE_RATIO'] = 1
        @options['DELETE_RATIO'] = 1
        @options['DROP_RATIO'] = 1

        @notes['MODELS'] = 'SINGLE - Use a single Database, MULTI - Use multiple databases (allow CREATE/DROP DATABASE)'
        @notes['DBASE_MINLEN'] = 'Minimum character length of a DATABASE\'S name'
        @notes['DBASE_MAXLEN'] = 'Maximum character length of a DATABASE\'S name'
        @notes['TABLE_MAXCNT'] = 'Maximum number of TABLES to allow in the database (-1, no restriction)'
        @notes['TABLE_MINLEN'] = 'Minimum character length of a TABLE\'S name'
        @notes['TABLE_MAXLEN'] = 'Maximum character length of a TABLE\'S name'
        @notes['COLUMN_MAXCNT'] = 'Maximum number of COLUMNS to allow per table'
        @notes['COLUMN_MINLEN'] = 'Minimum character length of a COLUMN\'S name'
        @notes['COLUMN_MAXLEN'] = 'Maximum character length of a COLUMN\'S name'

        @notes['CREATE_RATIO'] = 'Relative Ratio for CREATE commands (0 or less, ignore command type)'
        @notes['INSERT_RATIO'] = 'Relative Ratio for INSERT commands (0 or less, ignore command type)'
        @notes['SELECT_RATIO'] = 'Relative Ratio for SELECT commands (0 or less, ignore command type)'
        @notes['UPDATE_RATIO'] = 'Relative Ratio for UPDATE commands (0 or less, ignore command type)'
        @notes['DELETE_RATIO'] = 'Relative Ratio for DELETE commands (0 or less, ignore command type)'
        @notes['DROP_RATIO'] = 'Relative Ratio for DROP commands (0 or less, ignore command type)'
      end

      # returns (String) which the the domain that this expert specializes in
      def domain
        return 'SQL'
      end

      # prepare will setup the execution environment.  No tests will be executed but all required
      # resources and services will be prepared to execution.
      # return (bool) true if all of the components are read.
      def prepare
        @tests = Array.new

        items = %w(CREATE SELECT INSERT UPDATE DELETE DROP)
        items.each do |item|
          if @options["#{item}_RATIO"].to_i >= 1
            1.upto(@options["#{item}_RATIO"].to_i) do
              @tests.push item
            end
          end
        end

        super
      end

      # returns (Array of Strings) which lists all of the tests that the
      # expert currently supports, as various procedures are generated, different
      # tests become available or are not longer available.  The SQL expert is
      # partially stateful wrt constructing databases and tables.
      def tests
        if @database.length < 1
          return %w(CREATE)
        elsif @database.length == 1
          database = @database.keys[0]
          table_cnt = @database[database].length

          if table_cnt == 0
            return %w(CREATE)
          end
        end

        # all of the possible options, not all have been implemented.
        #%w( CREATE SELECT INSERT UPDATE DELETE DROP )
        return @tests
      end

      # returns (Array of Strings) which list all of the databases which
      # have been created (or should have been created)
      def databases
        return @database.keys
      end

      # return (String) the name of the active database which is being
      # manipulated.
      def active_database
        return @active
      end

      # database (String), name of the database to be added to the state model
      def add_database( database )
        unless has_database?( database )
          @database[database] = Hash.new
        end
      end

      # returns (bool) true if the database is within the state model
      def has_database?( database )
        return @database.keys.include?( database )
      end

      # deletes a database from the state model
      def delete_database( database )
        if has_database?( database )
          @database.delete database

          if database == @active
            if @database.keys.length > 0
              @active = @database.keys[0]
            else
              @active = ''
            end
          end
        end
      end

      # sets the active database to the value of datatase, provided that it
      # exists within the state model
      def use_database( database )
        if has_database?( database )
          @active = database
        end
      end

      # returns (Array of Strings) containing all of the names of the tables
      #                            within the specified database
      def tables( database )
        if has_database?( database )
          return @database[database].keys
        end

        return Array.new
      end

      # add a table to the active database
      # table (String) is the name of the table
      # fields (Hash) is a hash map of the columns that the table contains
      def add_table_to_active( table, fields )
        add_table( @active, table, fields )
      end

      # add a table to the specified database
      # database (String) is the name of the database that the table will be added to within the state model
      #                   if the database does not exist within the state model, one will be created
      # table (String) is the name of the table
      # fields (Hash) is a hash map of the columns that the table contains
      def add_table( database, table, fields )
        unless has_database?( database )
          add_database( database )
        end

        unless has_table?( database, table )
          @database[database][table] = fields
        end
      end

      # checks the state model to determine if the specified table exists within the specified database
      # database (String) name of the database to check
      # table (String) name of the table to check
      # returns (bool) true if, the table exists within the database
      def has_table?( database, table )
        if has_database?( database )
          return @database[database].keys.include?( table )
        end

        return false
      end

      # remove a table from the active database
      # table (String) name of the table to be removed from the state model
      def delete_table_from_active( table )
        delete_table( @active, table )
      end

      # remove a table from the specified database
      # database (String) name of the database to remove the table
      # table (String) name of the table to be removed from the database
      def delete_table( database, table )
        if has_table?( database, table )
          @database[database].delete( table )
        end
      end

      # obtain a list of columns within a specified table and database within the state model
      # database (String) name of the database
      # table (String) name of the table
      # return (Array of Strings) returns a list of column names of within the specified table from the database
      #                           if an invalid database or table is specified, an empty Array will be returned
      def columns( database, table )
        if has_table?( database, table )
          return @database[database][table].keys
        end

        return Array.new
      end

      # determine if a column exists within a table of a database
      # database (String) name of the database within the state model
      # table (String) name of the table
      # column (String) name of the column
      # return (bool) true if, the column exists within the specified database/table
      def has_column?( database, table, column )
        if has_table?( database, table )
          return @database[database][table].keys.include?( column )
        end

        return false
      end

      # obtain a list of columns from a table the active database within the state model
      # table (String) name of the table
      # return (Array of Strings) returns a list of column names of within the specified table from the active database
      #                           if an invalid database or table is specified, an empty Array will be returned
      def columns_from_active( table )
        columns( @active, table )
      end

      # obtain the details about a specific column within a table
      # database (String) name of the database within the state model
      # table (String) name of the table
      # column (String) name of the column
      # return (Hash) details about the column
      def column_details( database, table, column )
        if has_column?( database, table, column )
          return @database[database][table][column]
        end

        return Hash.new
      end

      # print a copy of the internal state model to the screen
      def show
        @database.each do |database,db_info|
          puts "Database   : #{database}"

          db_info.each do |table, tbl_info|
            puts "  Table    : #{table}"
            puts "    Columns: #{tbl_info.keys.inspect}"
            puts
          end
        end
      end

      # determine if the item passed is a procedure
      # procedure (Any), determine if the object is a Maadi::Procedure::Procedure
      # return (bool) true if, the object is a Maadi::Procedure::Procedure
      def is_procedure?( procedure )
        if procedure != nil
          if procedure.is_a?( Maadi::Procedure::Procedure )
            return true
          end
        end

        return false
      end

      # determine if the item passed is a step
      # step (Any), determine if the object is a Maadi::Procedure::Step
      # return (bool) true if, the object is a Maadi::Procedure::Step
      def is_step?( step )
        if step != nil
          if step.is_a?( Maadi::Procedure::Step )
            return true
          end
        end

        return false
      end

      # build/update a procedure for a specified test
      #   this function will mark a procedure as complete when all of the possible options
      #   have been specified.  Procedures built are assumed to have been successfully executed
      #   on an application so the state model will reflect any changes or updates that are
      #   expected to occur
      # test (String) name of a test build or update
      # procedure (Maadi::Procedure::Procedure) test procedure to be modified
      #                                         setting the value to nil, will cause a new procedure
      #                                         to be instantiated
      # return (Maadi::Procedure::Procedure) the procedure that was constructed based on current information
      def procedure( test, procedure )
        unless is_procedure?( procedure )
          procedure = build_skeleton( test )
        end

        case test.downcase
          when 'create'
            return manage_create( procedure )
          when 'select'
            return manage_select( procedure )
          when 'insert'
            return manage_insert( procedure )
          when 'update'
            return manage_update( procedure )
          when 'delete'
            return manage_delete( procedure )
          when 'drop'
            return manage_drop( procedure )
          else
        end

        return procedure
      end

      def build_skeleton( test )
        procedure = Maadi::Procedure::Procedure.new( test + '-NEW')
        return procedure
      end

      def build_create_new( next_step )
        procedure = build_skeleton( 'CREATE' )
        step = build_step('CREATE', 'COMPLETED', 'CREATE [TYPE]', 'TERM-PROC' )

        procedure.add_step( step )
        procedure.id = next_step

        return procedure
      end

      def build_add_create_type( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        if @options['MODELS'] == 'MULTI'
          constraint = Maadi::Procedure::ConstraintPickList.new( %w(DATABASE TABLE) )
          step.parameters.push Maadi::Procedure::Parameter.new('[CREATE-TYPE]', constraint )
        else
          constraint = Maadi::Procedure::ConstraintPickList.new( %w(TABLE) )
          step.parameters.push Maadi::Procedure::Parameter.new('[CREATE-TYPE]', constraint )
        end

        procedure.id = next_step
        return procedure
      end

      def build_add_create_database_name( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        if step.get_parameter_value( '[CREATE-TYPE]' ) == 'DATABASE'
          constraint = Maadi::Procedure::ConstraintSingleWord.new(@options['DBASE_MINLEN'].to_i,@options['DBASE_MAXLEN'].to_i)
          step.parameters.push Maadi::Procedure::Parameter.new('[DATABASE-NAME]', constraint )

          step.command = 'CREATE DATABASE [DATABASE-NAME]'

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_create_table_name( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        if step.get_parameter_value( '[CREATE-TYPE]' ) == 'TABLE'
          tbl_name =  Maadi::Procedure::ConstraintSingleWord.new( @options['TABLE_MINLEN'].to_i, @options['TABLE_MAXLEN'].to_i )
          step.parameters.push Maadi::Procedure::Parameter.new('[TABLE-NAME]', tbl_name)

          tbl_cols =  Maadi::Procedure::ConstraintRangedInteger.new( 1, @options['COLUMN_MAXCNT'].to_i )
          step.parameters.push Maadi::Procedure::Parameter.new('[TABLE-COLUMNS]', tbl_cols)

          step.command = 'CREATE TABLE [TABLE-NAME]'

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_create_table_columns( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        col_count = step.get_parameter_value('[TABLE-COLUMNS]')
        if col_count != ''
          parameters = procedure.steps[0].parameters
          columns = Array.new
          columns.push 'id INTEGER PRIMARY KEY'

          1.upto( col_count.to_i ) do |number|
            columns.push "[COLUMN#{number}-NAME] [COLUMN#{number}-TYPE]"

            col_name = Maadi::Procedure::ConstraintSingleWord.new( @options['COLUMN_MINLEN'].to_i, @options['COLUMN_MAXLEN'].to_i )
            parameters.push Maadi::Procedure::Parameter.new("[COLUMN#{number}-NAME]", col_name )

            col_type = Maadi::Procedure::ConstraintPickList.new( %w(INTEGER TEXT) )
            parameters.push Maadi::Procedure::Parameter.new("[COLUMN#{number}-TYPE]", col_type )
          end

          step.command = "CREATE TABLE [TABLE-NAME] ( #{columns.join(', ')} )"
          procedure.id = next_step
        end

        return procedure
      end

      def build_create_database_finalize( procedure, step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        step.id = 'CREATE-DATABASE'
        procedure.id = 'CREATE-DATABASE'

        database = step.get_parameter_value( '[DATABASE-NAME]' )
        if database != ''
          procedure.done
          add_database( database )
        else
          procedure.failed
        end

        return procedure
      end

      def build_create_table_finalize( procedure, step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        step.id = 'CREATE-TABLE'
        procedure.id = 'CREATE-TABLE'

        table = step.get_parameter_value( '[TABLE-NAME]' )
        if table != ''
          fields = Hash.new
          fields['id'] = Hash.new
          fields['id']['type'] = 'INTEGER'
          fields['id']['dflt'] = 'AUTO'
          fields['id']['pkey'] = true

          col_count = step.get_parameter_value('[TABLE-COLUMNS]')
          if col_count != ''
            1.upto( col_count.to_i ) do |number|
              column_name = step.get_parameter_value( "[COLUMN#{number}-NAME]" )
              column_type = step.get_parameter_value( "[COLUMN#{number}-TYPE]" )

              if ( column_name != '' ) && ( column_type != '' )
                fields[column_name] = Hash.new
                fields[column_name]['type'] = column_type
                fields[column_name]['dflt'] = ''
                fields[column_name]['pkey'] = false
              end
            end
          end

          procedure.done

          database = step.get_parameter_value( '[DATABASE-NAME]' )
          if database != ''
            add_table( database, table, fields )
          else
            add_table_to_active( table, fields )
          end
        else
          procedure.failed
        end

        return procedure
      end

      # build a SQL CREATE procedure
      # this will allow the construction of new TABLE or DATABASES
      # if the internal option is set to MULTI it will be possible to construct DATABASES and TABLES
      # otherwise this will only allow the construction of TABLES
      def manage_create( procedure )
        unless is_procedure?( procedure )
          return procedure
        end

        case procedure.id
          when 'CREATE-NEW'
            procedure = build_create_new( 'CREATE-NEW-NEXT' )
            return build_add_create_type( procedure, procedure.steps[0], 'CREATE-NEW-NEXT' )
          when 'CREATE-NEW-NEXT'
            case procedure.steps[0].get_parameter_value( '[CREATE-TYPE]' )
              when 'DATABASE'
                return build_add_redirect( procedure, procedure.steps[0], 'CREATE-DATABASE-NEW' )
              when 'TABLE'
                return build_add_redirect( procedure, procedure.steps[0], 'CREATE-TABLE-PICK-DATABASE' )
              else
                return procedure
            end
          when 'CREATE-DATABASE-NEW'
            return build_add_create_database_name( procedure, procedure.steps[0], 'CREATE-DATABASE-LAST' )
          when 'CREATE-DATABASE-LAST'
            return build_create_database_finalize( procedure, procedure.steps[0] )
          when 'CREATE-TABLE-PICK-DATABASE'
            return build_add_database_choice( procedure, procedure.steps[0], 'CREATE-TABLE-NEW' )
          when 'CREATE-TABLE-NEW'
            return build_add_create_table_name( procedure, procedure.steps[0], 'CREATE-TABLE-PARAMS' )
          when 'CREATE-TABLE-PARAMS'
            return build_add_create_table_columns( procedure, procedure.steps[0], 'CREATE-TABLE-LAST' )
          when 'CREATE-TABLE-LAST'
            return build_create_table_finalize( procedure, procedure.steps[0] )
          else
        end

        return procedure
      end

      def build_step( test, look_for, command, on_failure )
        parameters = Array.new
        step = Maadi::Procedure::Step.new(test + '-WIP', 'application', look_for, command, parameters, on_failure)
        return step
      end

      def build_select_new( next_step )
        procedure = build_skeleton( 'SELECT' )
        step = build_step('SELECT', 'COMPLETED', 'SELECT [USE-COLUMNS] FROM [TABLE-NAME] [USE-WHERE] [USE-ORDER-BY] [USE-LIMIT]', 'TERM-PROC' )

        procedure.add_step( step )
        procedure.id = next_step

        return procedure
      end

      def build_add_database_choice( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        constraint = Maadi::Procedure::ConstraintPickList.new( databases )
        step.parameters.push Maadi::Procedure::Parameter.new('[DATABASE-NAME]', constraint )

        procedure.id = next_step
        return procedure
      end

      def build_add_table_choice( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]' )

        if database != ''
          constraint = Maadi::Procedure::ConstraintPickList.new( tables(database) )
          step.parameters.push Maadi::Procedure::Parameter.new('[TABLE-NAME]', constraint )
        else
          constraint = Maadi::Procedure::ConstraintPickList.new( tables(@active) )
          step.parameters.push Maadi::Procedure::Parameter.new('[TABLE-NAME]', constraint )
        end

        procedure.id = next_step
        return procedure
      end

      def build_add_select_options( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]' )
        table = step.get_parameter_value( '[TABLE-NAME]' )

        if ( database != '' ) && ( table != '' )
          table_cols = columns( database, table )
          constraint = Maadi::Procedure::ConstraintConstant.new( table_cols.length.to_s )
          step.parameters.push Maadi::Procedure::Parameter.new('[TABLE-COLUMNS]', constraint )

          #constraint = Maadi::Procedure::ConstraintPickList.new( %w(MANY) )
          constraint = Maadi::Procedure::ConstraintPickList.new( %w(ONE MANY ALL) )
          step.parameters.push Maadi::Procedure::Parameter.new('[SELECT-COLUMNS]', constraint )

          build_add_where_option( procedure, step, next_step )

          build_add_order_by_option( procedure, step, next_step )

          build_add_limit_option( procedure, step, next_step )

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_select_single_column( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]')
        table = step.get_parameter_value( '[TABLE-NAME]' )
        sel_cols = step.get_parameter_value('[SELECT-COLUMNS]')

        if ( database != '' ) && ( table != '' ) && ( sel_cols == 'ONE' )
          constraint = Maadi::Procedure::ConstraintConstant.new( '[USE-DISTINCT] [COLUMN1-NAME]' )
          step.parameters.push Maadi::Procedure::Parameter.new('[USE-COLUMNS]', constraint )

          constraint = Maadi::Procedure::ConstraintPickList.new( %w(YES NO) )
          step.parameters.push Maadi::Procedure::Parameter.new('[DISTINCT-KEYWORD]', constraint )

          table_cols = columns( database, table )
          constraint = Maadi::Procedure::ConstraintPickList.new( table_cols )
          step.parameters.push Maadi::Procedure::Parameter.new('[COLUMN1-NAME]', constraint )

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_select_single_distinct( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        distinct = step.get_parameter_value( '[DISTINCT-KEYWORD]' )
        if distinct != ''
          if distinct == 'YES'
            constraint = Maadi::Procedure::ConstraintConstant.new( 'DISTINCT' )
            step.parameters.push Maadi::Procedure::Parameter.new('[USE-DISTINCT]', constraint )
          else
            constraint = Maadi::Procedure::ConstraintConstant.new( '' )
            step.parameters.push Maadi::Procedure::Parameter.new('[USE-DISTINCT]', constraint )
          end

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_select_many_columns( procedure, step, next_step )
        unless is_procedure?( procedure )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]')
        table = step.get_parameter_value( '[TABLE-NAME]' )
        sel_cols = step.get_parameter_value('[SELECT-COLUMNS]')

        if ( database != '' ) && ( table != '' ) && ( sel_cols == 'MANY' )
          table_cols = columns( database, table )
          constraint =  Maadi::Procedure::ConstraintRangedInteger.new( 1, table_cols.length )
          step.parameters.push Maadi::Procedure::Parameter.new('[USING-COLUMNS]', constraint )

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_select_many_use( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]')
        table = step.get_parameter_value( '[TABLE-NAME]' )
        num_cols = step.get_parameter_value('[USING-COLUMNS]')

        if ( database != '' ) && ( table != '' ) && ( num_cols != '' )
          table_cols = columns( database, table )
          use_cols = Array.new

          1.upto(num_cols.to_i) do |number|
            constraint = Maadi::Procedure::ConstraintPickList.new( table_cols )
            col_name = "[COLUMN#{number}-NAME]"
            step.parameters.push Maadi::Procedure::Parameter.new( col_name, constraint )
            use_cols.push col_name
          end

          constraint = Maadi::Procedure::ConstraintConstant.new( use_cols.join(', ') )
          step.parameters.push Maadi::Procedure::Parameter.new('[USE-COLUMNS]', constraint )

          procedure.id = next_step
        end

        return procedure
      end

      def build_remove_select_many_duplicates( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        num_cols = step.get_parameter_value('[USING-COLUMNS]')

        if num_cols != ''
          is_ok = true
          step.parameters.each do |parameter|
            if ( parameter.value != '' ) && ( parameter.label =~ /^\[COLUMN[0-9]/ )
              val_count = 0
              step.parameters.each do |param|
                if ( parameter.value == param.value ) && ( param.label =~ /^\[COLUMN[0-9]/ )
                  val_count += 1
                end
              end

              if val_count > 1
                parameter.value = ''
                is_ok = false
                break
              end
            end
          end

          procedure.id = next_step if is_ok
        end

        return procedure
      end

      def build_add_select_all_columns( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]')
        table = step.get_parameter_value( '[TABLE-NAME]' )
        sel_cols = step.get_parameter_value('[SELECT-COLUMNS]')

        if ( database != '' ) && ( table != '' ) && ( sel_cols == 'ALL' )
          constraint = Maadi::Procedure::ConstraintConstant.new( '*' )
          step.parameters.push Maadi::Procedure::Parameter.new('[USE-COLUMNS]', constraint )

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_where_option( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        #constraint = Maadi::Procedure::ConstraintPickList.new( %w(NO) )
        constraint = Maadi::Procedure::ConstraintPickList.new( %w(YES NO) )
        step.parameters.push Maadi::Procedure::Parameter.new('[WHERE-CLAUSE]', constraint )

        procedure.id = next_step
        return procedure
      end

      def build_add_where_type_choice( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        if step.get_parameter_value('[WHERE-CLAUSE]') == 'YES'
          constraint = Maadi::Procedure::ConstraintPickList.new( %w(SIMPLE) )
          step.parameters.push Maadi::Procedure::Parameter.new('[WHERE-TYPE]', constraint )

          procedure.id = next_step
          return procedure
        end

        return procedure
      end

      def build_add_where_simple_options( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]' )
        table = step.get_parameter_value( '[TABLE-NAME]' )

        if ( database != '' ) && ( table != '' )
          if step.get_parameter_value( '[WHERE-TYPE]' )  == 'SIMPLE'
            table_cols = columns( database, table )
            constraint =  Maadi::Procedure::ConstraintRangedInteger.new( 1, table_cols.length )
            step.parameters.push Maadi::Procedure::Parameter.new('[WHERE-COLUMNS]', constraint )

            constraint =  Maadi::Procedure::ConstraintPickList.new( %w(AND OR) )
            step.parameters.push Maadi::Procedure::Parameter.new('[WHERE-CHAIN]', constraint )

            procedure.id = next_step
          end
        end

        return procedure
      end

      def build_add_where_column_options( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]' )
        table = step.get_parameter_value( '[TABLE-NAME]' )
        num_wheres = step.get_parameter_value('[WHERE-COLUMNS]' )

        if ( database != '' ) && ( table != '' ) && ( num_wheres != '' )
          table_cols = columns( database, table )

          1.upto(num_wheres.to_i) do |number|
            constraint = Maadi::Procedure::ConstraintPickList.new( table_cols )
            col_name = "[WHERE#{number}-NAME]"
            step.parameters.push Maadi::Procedure::Parameter.new( col_name, constraint )

            constraint = Maadi::Procedure::ConstraintPickList.new( %w(EQ NE LT GT LE GE) )
            col_name = "[WHERE#{number}-OPER]"
            step.parameters.push Maadi::Procedure::Parameter.new( col_name, constraint )
          end

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_where_simple_use( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]')
        table = step.get_parameter_value( '[TABLE-NAME]' )
        num_wheres = step.get_parameter_value('[WHERE-COLUMNS]')
        cls_chain = step.get_parameter_value('[WHERE-CHAIN]')

        if ( database != '' ) && ( table != '' ) && ( num_wheres != '' ) && ( cls_chain != '' )
          use_wheres = Array.new

          1.upto( num_wheres.to_i ) do |number|
            col_name = step.get_parameter_value("[WHERE#{number}-NAME]")
            col_oper = step.get_parameter_value("[WHERE#{number}-OPER]")

            if ( col_name != '' ) && ( col_oper != '' )
              col_info = column_details( database, table, col_name )

              case col_info['type']
                when 'INTEGER'
                  constraint = Maadi::Procedure::ConstraintRangedInteger.new( 0, 1024 )
                  step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-VALUE]", constraint )

                  case col_oper
                    when 'EQ'
                      constraint = Maadi::Procedure::ConstraintConstant.new( '=' )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-COMP]", constraint )
                    when 'NE'
                      constraint = Maadi::Procedure::ConstraintConstant.new( '<>' )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-COMP]", constraint )
                    when 'LT'
                      constraint = Maadi::Procedure::ConstraintConstant.new( '<' )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-COMP]", constraint )
                    when 'GT'
                      constraint = Maadi::Procedure::ConstraintConstant.new( '>' )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-COMP]", constraint )
                    when 'LE'
                      constraint = Maadi::Procedure::ConstraintConstant.new( '<=' )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-COMP]", constraint )
                    when 'GE'
                      constraint = Maadi::Procedure::ConstraintConstant.new( '>=' )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-COMP]", constraint )
                    else
                  end

                  use_wheres.push "[WHERE#{number}-NAME] [WHERE#{number}-COMP] [WHERE#{number}-VALUE]"
                when 'TEXT'
                  constraint = Maadi::Procedure::ConstraintSingleWord.new( 2, 4 )
                  step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-VALUE]", constraint)

                  case col_oper
                    when 'EQ'
                      constraint = Maadi::Procedure::ConstraintConstant.new( 'LIKE' )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-COMP]", constraint )

                      constraint = Maadi::Procedure::ConstraintConstant.new( "\"%[WHERE#{number}-VALUE]%\"" )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-LIKE]", constraint )
                    when 'NE'
                      constraint = Maadi::Procedure::ConstraintConstant.new( 'NOT LIKE' )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-COMP]", constraint )

                      constraint = Maadi::Procedure::ConstraintConstant.new( "\"%[WHERE#{number}-VALUE]%\"" )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-LIKE]", constraint )
                    when 'LT'
                      constraint = Maadi::Procedure::ConstraintConstant.new( 'NOT LIKE' )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-COMP]", constraint )

                      constraint = Maadi::Procedure::ConstraintConstant.new( "\"[WHERE#{number}-VALUE]%\"" )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-LIKE]", constraint )
                    when 'GT'
                      constraint = Maadi::Procedure::ConstraintConstant.new( 'NOT LIKE' )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-COMP]", constraint )

                      constraint = Maadi::Procedure::ConstraintConstant.new( "\"%[WHERE#{number}-VALUE]\"" )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-LIKE]", constraint )
                    when 'LE'
                      constraint = Maadi::Procedure::ConstraintConstant.new( 'LIKE' )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-COMP]", constraint )

                      constraint = Maadi::Procedure::ConstraintConstant.new( "\"[WHERE#{number}-VALUE]%\"" )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-LIKE]", constraint )
                    when 'GE'
                      constraint = Maadi::Procedure::ConstraintConstant.new( 'LIKE' )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-COMP]", constraint )

                      constraint = Maadi::Procedure::ConstraintConstant.new( "\"%[WHERE#{number}-VALUE]\"" )
                      step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-LIKE]", constraint )
                    else
                  end

                  use_wheres.push "[WHERE#{number}-NAME] [WHERE#{number}-COMP] [WHERE#{number}-LIKE]"
                else
                  constraint = Maadi::Procedure::ConstraintConstant.new( "UNKNOWN TYPE[#{col_info['type']}]" )
                  step.parameters.push Maadi::Procedure::Parameter.new("[WHERE#{number}-VALUE]", constraint )
              end
            end
          end

          constraint = Maadi::Procedure::ConstraintConstant.new( 'WHERE ' + use_wheres.join(' ' + cls_chain + ' ') )
          step.parameters.push Maadi::Procedure::Parameter.new('[USE-WHERE]', constraint )

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_where_no_use( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        if step.get_parameter_value('[WHERE-CLAUSE]') != 'YES'
          constraint = Maadi::Procedure::ConstraintConstant.new( '' )
          step.parameters.push Maadi::Procedure::Parameter.new( '[USE-WHERE]', constraint )

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_order_by_option( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        #constraint = Maadi::Procedure::ConstraintPickList.new( %w(NO) )
        constraint = Maadi::Procedure::ConstraintPickList.new( %w(YES NO) )
        step.parameters.push Maadi::Procedure::Parameter.new('[ORDER-BY-CLAUSE]', constraint )

        procedure.id = next_step
        return procedure
      end

      def build_add_order_by_many_columns( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]' )
        table = step.get_parameter_value( '[TABLE-NAME]' )
        use_order = step.get_parameter_value( '[ORDER-BY-CLAUSE]' )
        sel_cols = step.get_parameter_value( '[SELECT-COLUMNS]' )

        if ( database != '' ) && ( table != '' ) && ( use_order != '' ) && ( sel_cols != '' )
          if step.get_parameter_value( '[ORDER-BY-CLAUSE]' ) == 'YES'
            case sel_cols
              when 'ONE'
                constraint = Maadi::Procedure::ConstraintConstant.new( '1' )
                step.parameters.push Maadi::Procedure::Parameter.new('[ORDER-COLUMNS]', constraint )

              when 'MANY'
                use_cols = step.get_parameter_value( '[USING-COLUMNS]' )
                constraint =  Maadi::Procedure::ConstraintRangedInteger.new( 1, use_cols.to_i )
                step.parameters.push Maadi::Procedure::Parameter.new('[ORDER-COLUMNS]', constraint )

              when 'ALL'
                table_cols = columns( database, table )
                constraint =  Maadi::Procedure::ConstraintRangedInteger.new( 1, table_cols.length )
                step.parameters.push Maadi::Procedure::Parameter.new('[ORDER-COLUMNS]', constraint )
              else
            end

            procedure.id = next_step
            return procedure
          end
        end

        return procedure
      end

      def build_add_order_by_many_use( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]' )
        table = step.get_parameter_value( '[TABLE-NAME]' )
        sel_cols = step.get_parameter_value( '[SELECT-COLUMNS]' )
        use_cols = step.get_parameter_value( '[ORDER-COLUMNS]' )

        if ( database != '' ) && ( table != '' ) && ( sel_cols != '' ) && ( use_cols != '' )
          ordering = [ ' ', 'ASC', 'DESC']

          case sel_cols
            when 'ONE'
              constraint = Maadi::Procedure::ConstraintConstant.new( '[COLUMN1-NAME]' )
              step.parameters.push Maadi::Procedure::Parameter.new('[ORDER1-NAME]', constraint )

              constraint = Maadi::Procedure::ConstraintPickList.new( ordering )
              step.parameters.push Maadi::Procedure::Parameter.new('[ORDER1-VALUE]', constraint )

              constraint = Maadi::Procedure::ConstraintConstant.new( 'ORDER BY [ORDER1-NAME] [ORDER1-VALUE]' )
              step.parameters.push Maadi::Procedure::Parameter.new('[USE-ORDER-BY]', constraint )
            when 'MANY'
              sel_cnt = step.get_parameter_value( '[USING-COLUMNS]' )
              if sel_cnt != ''
                table_cols = Array.new
                1.upto(use_cols.to_i) do |number|
                  col_name = step.get_parameter_value("[COLUMN#{number}-NAME]")
                  table_cols.push col_name if col_name != ''
                end

                #table_cols = columns( database, table )
                use_orders = Array.new

                1.upto(use_cols.to_i) do |number|
                  constraint =  Maadi::Procedure::ConstraintPickList.new( table_cols )
                  step.parameters.push Maadi::Procedure::Parameter.new("[ORDER#{number}-NAME]", constraint )

                  constraint = Maadi::Procedure::ConstraintPickList.new( ordering )
                  step.parameters.push Maadi::Procedure::Parameter.new("[ORDER#{number}-VALUE]", constraint )

                  use_orders.push "[ORDER#{number}-NAME] [ORDER#{number}-VALUE]"
                end

                constraint = Maadi::Procedure::ConstraintConstant.new( 'ORDER BY ' + use_orders.join(', ') )
                step.parameters.push Maadi::Procedure::Parameter.new('[USE-ORDER-BY]', constraint )
             end
            when 'ALL'
              table_cols = columns( database, table )
              use_orders = Array.new

              1.upto(use_cols.to_i) do |number|
                constraint =  Maadi::Procedure::ConstraintPickList.new( table_cols )
                step.parameters.push Maadi::Procedure::Parameter.new("[ORDER#{number}-NAME]", constraint )

                constraint = Maadi::Procedure::ConstraintPickList.new( ordering )
                step.parameters.push Maadi::Procedure::Parameter.new("[ORDER#{number}-VALUE]", constraint )

                use_orders.push "[ORDER#{number}-NAME] [ORDER#{number}-VALUE]"
              end

              constraint = Maadi::Procedure::ConstraintConstant.new( 'ORDER BY ' + use_orders.join(', ') )
              step.parameters.push Maadi::Procedure::Parameter.new('[USE-ORDER-BY]', constraint )
            else
          end

          procedure.id = next_step
          return procedure
        end

        return procedure
      end

      def build_remove_order_by_many_duplicates( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        num_cols = step.get_parameter_value('[ORDER-COLUMNS]')

        if num_cols != ''
          is_ok = true
          step.parameters.each do |parameter|
            if ( parameter.value != '' ) && ( parameter.label =~ /^\[ORDER[0-9]/ )
              val_count = 0
              step.parameters.each do |param|
                if ( parameter.value == param.value ) && ( param.label =~ /^\[ORDER[0-9]/ )
                  val_count += 1
                end
              end

              if val_count > 1
                parameter.value = ''
                is_ok = false
                break
              end
            end
          end

          procedure.id = next_step if is_ok
        end

        return procedure
      end

      def build_add_order_by_no_use( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        if step.get_parameter_value( '[ORDER-BY-CLAUSE]' ) != 'YES'
          constraint = Maadi::Procedure::ConstraintConstant.new( '' )
          step.parameters.push Maadi::Procedure::Parameter.new('[USE-ORDER-BY]', constraint )

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_limit_option( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        #constraint = Maadi::Procedure::ConstraintPickList.new( %w(YES) )
        constraint = Maadi::Procedure::ConstraintPickList.new( %w(YES NO) )
        step.parameters.push Maadi::Procedure::Parameter.new('[LIMIT-CLAUSE]', constraint )

        procedure.id = next_step
        return procedure
      end

      def build_add_limit_offset_option( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        if step.get_parameter_value('[LIMIT-CLAUSE]') == 'YES'
          constraint = Maadi::Procedure::ConstraintPickList.new( %w(YES NO) )
          step.parameters.push Maadi::Procedure::Parameter.new('[OFFSET-CLAUSE]', constraint )

          constraint = Maadi::Procedure::ConstraintRangedInteger.new( 0, 50 )
          step.parameters.push Maadi::Procedure::Parameter.new('[LIMIT-VALUE]', constraint )

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_limit_use( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        if step.get_parameter_value('[OFFSET-CLAUSE]') != 'YES'
          constraint = Maadi::Procedure::ConstraintConstant.new( 'LIMIT [LIMIT-VALUE]' )
          step.parameters.push Maadi::Procedure::Parameter.new('[USE-LIMIT]', constraint )

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_limit_offset_use( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        if step.get_parameter_value('[OFFSET-CLAUSE]') == 'YES'
          constraint = Maadi::Procedure::ConstraintRangedInteger.new( 0, 50 )
          step.parameters.push Maadi::Procedure::Parameter.new('[OFFSET-VALUE]', constraint )

          constraint = Maadi::Procedure::ConstraintConstant.new( 'LIMIT [OFFSET-VALUE], [LIMIT-VALUE]' )
          step.parameters.push Maadi::Procedure::Parameter.new('[USE-LIMIT]', constraint )

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_limit_no_use( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        if step.get_parameter_value( '[LIMIT-CLAUSE]' ) != 'YES'
          constraint = Maadi::Procedure::ConstraintConstant.new( '' )
          step.parameters.push Maadi::Procedure::Parameter.new('[USE-LIMIT]', constraint )

          procedure.id = next_step
        end

        return procedure
      end

      def build_select_finalize( procedure, step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        step.id = 'SELECT'
        procedure.id = 'SELECT'
        procedure.done

        return procedure
      end

      def manage_select( procedure )
        unless is_procedure?( procedure )
          return procedure
        end

        case procedure.id
          when 'SELECT-NEW'
            procedure = build_select_new( 'SELECT-NEW-PICK-DATABASE' )
            return build_add_database_choice( procedure, procedure.steps[0], 'SELECT-NEW-PICK-DATABASE' )
          when 'SELECT-NEW-PICK-DATABASE'
            return build_add_table_choice( procedure, procedure.steps[0], 'SELECT-NEW-PICK-TABLE' )
          when 'SELECT-NEW-PICK-TABLE'
            return build_add_select_options( procedure, procedure.steps[0], 'SELECT-NEW-COLUMNS' )
          when 'SELECT-NEW-COLUMNS'
            case procedure.steps[0].get_parameter_value( '[SELECT-COLUMNS]' )
              when 'ONE'
                return build_add_select_single_column( procedure, procedure.steps[0], 'SELECT-NEW-DISTINCT')
              when 'MANY'
                return build_add_select_many_columns( procedure, procedure.steps[0], 'SELECT-NEW-COLUMNS-MANY' )
              when 'ALL'
                return build_add_select_all_columns( procedure, procedure.steps[0], 'SELECT-NEW-WHERE' )
              else
            end

            return procedure
          when 'SELECT-NEW-COLUMNS-MANY'
            return build_add_select_many_use( procedure, procedure.steps[0], 'SELECT-NEW-COLUMNS-LAST' )
          when 'SELECT-NEW-COLUMNS-LAST'
            return build_remove_select_many_duplicates( procedure, procedure.steps[0], 'SELECT-NEW-WHERE' )
          when 'SELECT-NEW-DISTINCT'
            return build_add_select_single_distinct( procedure, procedure.steps[0], 'SELECT-NEW-WHERE' )
          when 'SELECT-NEW-WHERE'
            case procedure.steps[0].get_parameter_value( '[WHERE-CLAUSE]' )
              when 'YES'
                return build_add_where_type_choice( procedure, procedure.steps[0], 'SELECT-NEW-WHERE-TYPE' )
              else
                return build_add_where_no_use( procedure, procedure.steps[0], 'SELECT-NEW-ORDER-BY' )
            end
          when 'SELECT-NEW-WHERE-TYPE'
            case procedure.steps[0].get_parameter_value( '[WHERE-TYPE]' )
              when 'SIMPLE'
                return build_add_where_simple_options( procedure, procedure.steps[0], 'SELECT-NEW-WHERE-PICK' )
              else
                # invalid value for the where type, ignore and use nothing for the where clause
                return build_add_where_no_use( procedure, procedure.steps[0], 'SELECT-NEW-ORDER-BY' )
            end
          when 'SELECT-NEW-WHERE-PICK'
            return build_add_where_column_options( procedure, procedure.steps[0], 'SELECT-NEW-WHERE-BUILD' )
          when 'SELECT-NEW-WHERE-BUILD'
            return build_add_where_simple_use( procedure, procedure.steps[0], 'SELECT-NEW-ORDER-BY' )
          when 'SELECT-NEW-ORDER-BY'
            case procedure.steps[0].get_parameter_value( '[ORDER-BY-CLAUSE]' )
              when 'YES'
                return build_add_order_by_many_columns( procedure, procedure.steps[0], 'SELECT-NEW-ORDER-BY-PICK' )
              else
                return build_add_order_by_no_use( procedure, procedure.steps[0], 'SELECT-NEW-LIMIT' )
            end
          when 'SELECT-NEW-ORDER-BY-PICK'
            return build_add_order_by_many_use( procedure, procedure.steps[0], 'SELECT-NEW-ORDER-BY-LAST' )
          when 'SELECT-NEW-ORDER-BY-LAST'
            return build_remove_order_by_many_duplicates( procedure, procedure.steps[0], 'SELECT-NEW-LIMIT' )
          when 'SELECT-NEW-LIMIT'
            case procedure.steps[0].get_parameter_value( '[LIMIT-CLAUSE]' )
              when 'YES'
                return build_add_limit_offset_option( procedure, procedure.steps[0], 'SELECT-NEW-LIMIT-OFFSET' )
              else
                return build_add_limit_no_use( procedure, procedure.steps[0], 'SELECT-LAST' )
            end
          when 'SELECT-NEW-LIMIT-OFFSET'
            case procedure.steps[0].get_parameter_value( '[OFFSET-CLAUSE]' )
              when 'YES'
                return build_add_limit_offset_use( procedure, procedure.steps[0], 'SELECT-LAST' )
              else
                return build_add_limit_use( procedure, procedure.steps[0], 'SELECT-LAST' )
            end
          when 'SELECT-LAST'
            return build_select_finalize( procedure, procedure.steps[0] )
          else
        end

        return procedure
      end

      def build_insert_new( next_step )
        procedure = build_skeleton( 'INSERT' )
        step = build_step('INSERT', 'CHANGES', 'INSERT INTO [TYPE]', 'TERM-PROC' )

        procedure.add_step( step )
        procedure.id = next_step

        return procedure
      end

      def build_add_insert_options( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        if step.get_parameter_value( '[TABLE-NAME]')
          constraint = Maadi::Procedure::ConstraintPickList.new( %w(SPECIFIED IMPLICIT) )
          #constraint = Maadi::Procedure::ConstraintPickList.new( %w(SPECIFIED IMPLICIT MULITROW) )
          procedure.steps[0].parameters.push Maadi::Procedure::Parameter.new('[INSERT-TYPE]', constraint )

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_redirect( procedure, step, next_step, failed = false )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        procedure.id = next_step

        if failed
          procedure.failed
        end

        return procedure
      end

      def build_add_insert_specified_options( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]' )
        table = step.get_parameter_value( '[TABLE-NAME]' )
        if ( database != '' ) && ( table != '' )
          cols = columns( database, table )

          cols_labels = Array.new
          cols_values = Array.new

          number = 0
          cols.each do |col_name|
            cols_detail = column_details( database, table, col_name )
            if cols_detail['pkey']
              #cols_values.push '0'
            else
              cols_labels.push col_name
              cols_values.push "[COLUMN#{number}-VALUE]"
              col_type = Maadi::Procedure::ConstraintConstant.new( cols_detail['type'] )
              step.parameters.push Maadi::Procedure::Parameter.new("[COLUMN#{number}-TYPE]", col_type )

              case cols_detail['type']
                when 'INTEGER'
                  constraint = Maadi::Procedure::ConstraintRangedInteger.new( 0, 1024 )
                  step.parameters.push Maadi::Procedure::Parameter.new("[COLUMN#{number}-VALUE]", constraint )
                when 'TEXT'
                  constraint = Maadi::Procedure::ConstraintMultiWord.new( 5, 10, 1, 100, ' ' )
                  step.parameters.push Maadi::Procedure::Parameter.new("[COLUMN#{number}-VALUE]", constraint, '"')
                else
                  constraint = Maadi::Procedure::ConstraintConstant.new( "UNKNOWN TYPE[#{cols_detail['type']}]" )
                  step.parameters.push Maadi::Procedure::Parameter.new("[COLUMN#{number}-VALUE]", constraint )
              end
            end

            procedure.steps[0].command = "INSERT INTO [TABLE-NAME](#{cols_labels.join(', ')}) VALUES( #{cols_values.join(', ')} )"
            number += 1
          end

          constraint = Maadi::Procedure::ConstraintConstant.new( number.to_s )
          step.parameters.push Maadi::Procedure::Parameter.new('[TABLE-COLUMNS]', constraint )

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_insert_implicit_options( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]' )
        table = step.get_parameter_value( '[TABLE-NAME]' )
        if ( database != '' ) && ( table != '' )
          cols = columns( database, table )

          #cols_labels = Array.new
          cols_values = Array.new

          number = 0
          cols.each do |col_name|
            cols_detail = column_details( database, table, col_name )
            #cols_labels.push col_name
            if cols_detail['pkey']
              cols_values.push '0'
            else
              cols_values.push "[COLUMN#{number}-VALUE]"
              col_type = Maadi::Procedure::ConstraintConstant.new( cols_detail['type'] )
              procedure.steps[0].parameters.push Maadi::Procedure::Parameter.new("[COLUMN#{number}-TYPE]", col_type )

              case cols_detail['type']
                when 'INTEGER'
                  constraint =  Maadi::Procedure::ConstraintRangedInteger.new( 0, 1024 )
                  procedure.steps[0].parameters.push Maadi::Procedure::Parameter.new("[COLUMN#{number}-VALUE]", constraint )
                when 'TEXT'
                  constraint = Maadi::Procedure::ConstraintMultiWord.new( 5, 10, 1, 100, ' ' )
                  procedure.steps[0].parameters.push Maadi::Procedure::Parameter.new("[COLUMN#{number}-VALUE]", constraint, '"')
                else
                  constraint = Maadi::Procedure::ConstraintConstant.new( "UNKNOWN TYPE[#{cols_detail['type']}]" )
                  procedure.steps[0].parameters.push Maadi::Procedure::Parameter.new("[COLUMN#{number}-VALUE]", constraint )
              end
            end

            procedure.steps[0].command = "INSERT INTO [TABLE-NAME] VALUES( #{cols_values.join(', ')} )"
            number += 1
          end
          procedure.steps[0].parameters.push Maadi::Procedure::Parameter.new('[TABLE-COLUMNS]', Maadi::Procedure::ConstraintConstant.new( number.to_s ))

          procedure.id = next_step
        end

        return procedure
      end

      def build_insert_specified_finalize( procedure, step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        step.id = 'INSERT-SPECIFIED'
        procedure.id = 'INSERT-SPECIFIED'
        procedure.done

        return procedure
      end

      def build_insert_implicit_finalize( procedure, step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        step.id = 'INSERT-IMPLICIT'
        procedure.id = 'INSERT-IMPLICIT'
        procedure.done

        return procedure
      end

      def manage_insert( procedure )
        unless is_procedure?( procedure )
          return procedure
        end

        case procedure.id
          when 'INSERT-NEW'
            procedure = build_insert_new( 'INSERT-NEW-PICK-DATABASE' )
            return build_add_database_choice( procedure, procedure.steps[0], 'INSERT-NEW-PICK-DATABASE' )
          when 'INSERT-NEW-PICK-DATABASE'
            return build_add_table_choice( procedure, procedure.steps[0], 'INSERT-NEW-PICK-TABLE' )
          when 'INSERT-NEW-PICK-TABLE'
            return build_add_insert_options( procedure, procedure.steps[0], 'INSERT-NEW-NEXT' )
          when 'INSERT-NEW-NEXT'
            case procedure.steps[0].get_parameter_value( '[INSERT-TYPE]' )
              when 'SPECIFIED'
                return build_add_redirect( procedure, procedure.steps[0], 'INSERT-SPECIFIED-NEW' )
              when 'IMPLICIT'
                return build_add_redirect( procedure, procedure.steps[0], 'INSERT-IMPLICIT-NEW' )
              when 'MULTIROW'
                return build_add_redirect( procedure, procedure.steps[0], 'INSERT-MULTIROW-NEW', true )
              else
            end

            return procedure
          when 'INSERT-SPECIFIED-NEW'
            return build_add_insert_specified_options( procedure, procedure.steps[0], 'INSERT-SPECIFIED-LAST' )
          when 'INSERT-SPECIFIED-LAST'
            return build_insert_specified_finalize( procedure, procedure.steps[0] )
          when 'INSERT-IMPLICIT-NEW'
             return build_add_insert_implicit_options( procedure, procedure.steps[0], 'INSERT-IMPLICIT-LAST' )
          when 'INSERT-IMPLICIT-LAST'
            return build_insert_implicit_finalize( procedure, procedure.steps[0] )
          else
        end

        return procedure
      end

      def build_update_new( next_step )
        procedure = build_skeleton( 'UPDATE' )
        step = build_step('UPDATE', 'CHANGES', 'UPDATE [TABLE-NAME] SET [USE-SET] [USE-WHERE]', 'TERM-PROC' )

        procedure.add_step( step )
        procedure.id = next_step

        return procedure
      end

      def build_add_update_options( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]' )
        table = step.get_parameter_value( '[TABLE-NAME]' )

        if ( database != '' ) && ( table != '' )
          table_cols = columns( database, table )
          constraint = Maadi::Procedure::ConstraintConstant.new( table_cols.length.to_s )
          step.parameters.push Maadi::Procedure::Parameter.new('[TABLE-COLUMNS]', constraint )

          constraint =  Maadi::Procedure::ConstraintRangedInteger.new( 1, table_cols.length - 1 )
          step.parameters.push Maadi::Procedure::Parameter.new('[USING-COLUMNS]', constraint )

          build_add_where_option( procedure, step, next_step )

          procedure.id = next_step
        end

        return procedure
      end

      def build_add_update_use( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]')
        table = step.get_parameter_value( '[TABLE-NAME]' )
        num_cols = step.get_parameter_value('[USING-COLUMNS]')

        if ( database != '' ) && ( table != '' ) && ( num_cols != '' )
          table_cols = columns( database, table )
          table_cols.delete( 'id' )
          use_cols = Array.new

          1.upto(num_cols.to_i) do |number|
            col_name = "[COLUMN#{number}-NAME]"
            constraint = Maadi::Procedure::ConstraintPickList.new( table_cols )
            step.parameters.push Maadi::Procedure::Parameter.new( col_name, constraint )
            use_cols.push col_name
          end

          #constraint = Maadi::Procedure::ConstraintConstant.new( use_cols.join(', ') )
          #step.parameters.push Maadi::Procedure::Parameter.new('[USE-SET]', constraint )

          procedure.id = next_step
        end

        return procedure
      end

      def build_remove_update_duplicates( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        num_cols = step.get_parameter_value('[USING-COLUMNS]')

        if num_cols != ''
          is_ok = true
          step.parameters.each do |parameter|
            if ( parameter.value != '' ) && ( parameter.label =~ /^\[COLUMN[0-9]/ )
              val_count = 0
              step.parameters.each do |param|
                if ( parameter.value == param.value ) && ( param.label =~ /^\[COLUMN[0-9]/ )
                  val_count += 1
                end
              end

              if val_count > 1
                parameter.value = ''
                is_ok = false
                break
              end
            end
          end

          procedure.id = next_step if is_ok
        end

        return procedure
      end

      def build_add_update_bind_columns( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]')
        table = step.get_parameter_value( '[TABLE-NAME]' )
        num_cols = step.get_parameter_value('[USING-COLUMNS]')
        if ( database != '' ) && ( table != '' ) && ( num_cols != '' )
          use_sets = Array.new

          1.upto( num_cols.to_i ) do |number|
            col_name = step.get_parameter_value("[COLUMN#{number}-NAME]")

            if col_name != ''
              col_info = column_details( database, table, col_name )

              case col_info['type']
                when 'INTEGER'
                  constraint = Maadi::Procedure::ConstraintRangedInteger.new( 0, 1024 )
                  step.parameters.push Maadi::Procedure::Parameter.new("[COLUMN#{number}-VALUE]", constraint )
                when 'TEXT'
                  constraint = Maadi::Procedure::ConstraintMultiWord.new( 5, 10, 1, 100, ' ' )
                  step.parameters.push Maadi::Procedure::Parameter.new("[COLUMN#{number}-VALUE]", constraint, '"')
                else
                  constraint = Maadi::Procedure::ConstraintConstant.new( "UNKNOWN TYPE[#{col_info['type']}]" )
                  step.parameters.push Maadi::Procedure::Parameter.new("[COLUMN#{number}-VALUE]", constraint )
              end

              use_sets.push "[COLUMN#{number}-NAME] = [COLUMN#{number}-VALUE]"
            end
          end

          constraint = Maadi::Procedure::ConstraintConstant.new( use_sets.join(', ') )
          step.parameters.push Maadi::Procedure::Parameter.new('[USE-SET]', constraint )

          procedure.id = next_step
        end

        return procedure
      end


      def build_update_finalize( procedure, step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        step.id = 'UPDATE'
        procedure.id = 'UPDATE'
        procedure.done

        return procedure
      end

      def manage_update( procedure )
        unless is_procedure?( procedure )
          return procedure
        end

        case procedure.id
          when 'UPDATE-NEW'
            procedure = build_update_new( 'UPDATE-NEW-PICK-DATABASE' )
            return build_add_database_choice( procedure, procedure.steps[0], 'UPDATE-NEW-PICK-DATABASE' )
          when 'UPDATE-NEW-PICK-DATABASE'
            return build_add_table_choice( procedure, procedure.steps[0], 'UPDATE-NEW-PICK-TABLE' )
          when 'UPDATE-NEW-PICK-TABLE'
            return build_add_update_options( procedure, procedure.steps[0], 'UPDATE-NEW-COLUMNS' )
          when 'UPDATE-NEW-COLUMNS'
            return build_add_update_use( procedure, procedure.steps[0], 'UPDATE-NEW-COLUMNS-NEXT' )
          when 'UPDATE-NEW-COLUMNS-NEXT'
            return build_remove_update_duplicates( procedure, procedure.steps[0], 'UPDATE-NEW-COLUMNS-LAST' )
          when 'UPDATE-NEW-COLUMNS-LAST'
            return build_add_update_bind_columns( procedure, procedure.steps[0], 'UPDATE-NEW-WHERE' )
          when 'UPDATE-NEW-WHERE'
            case procedure.steps[0].get_parameter_value( '[WHERE-CLAUSE]' )
              when 'YES'
                return build_add_where_type_choice( procedure, procedure.steps[0], 'UPDATE-NEW-WHERE-TYPE' )
              else
                return build_add_where_no_use( procedure, procedure.steps[0], 'UPDATE-LAST' )
            end
          when 'UPDATE-NEW-WHERE-TYPE'
            case procedure.steps[0].get_parameter_value( '[WHERE-TYPE]' )
              when 'SIMPLE'
                return build_add_where_simple_options( procedure, procedure.steps[0], 'UPDATE-NEW-WHERE-PICK' )
              else
                # invalid value for the where type, ignore and use nothing for the where clause
                return build_add_where_no_use( procedure, procedure.steps[0], 'UPDATE-LAST' )
            end
          when 'UPDATE-NEW-WHERE-PICK'
            return build_add_where_column_options( procedure, procedure.steps[0], 'UPDATE-NEW-WHERE-BUILD' )
          when 'UPDATE-NEW-WHERE-BUILD'
            return build_add_where_simple_use( procedure, procedure.steps[0], 'UPDATE-LAST' )
          when 'UPDATE-LAST'
            return build_update_finalize( procedure, procedure.steps[0] )
          else
        end

        return procedure
      end

      def build_delete_new( next_step )
        procedure = build_skeleton( 'DELETE' )
        step = build_step('DELETE', 'CHANGES', 'DELETE FROM [TABLE-NAME] [USE-WHERE]', 'TERM-PROC' )

        procedure.add_step( step )
        procedure.id = next_step

        return procedure
      end

      def build_add_delete_options( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        database = step.get_parameter_value( '[DATABASE-NAME]' )
        table = step.get_parameter_value( '[TABLE-NAME]' )

        if ( database != '' ) && ( table != '' )
          table_cols = columns( database, table )
          constraint = Maadi::Procedure::ConstraintConstant.new( table_cols.length.to_s )
          step.parameters.push Maadi::Procedure::Parameter.new('[TABLE-COLUMNS]', constraint )

          #constraint = Maadi::Procedure::ConstraintPickList.new( %w(MANY) )
          #constraint = Maadi::Procedure::ConstraintPickList.new( %w(ONE MANY ALL) )
          #step.parameters.push Maadi::Procedure::Parameter.new('[SELECT-COLUMNS]', constraint )

          build_add_where_option( procedure, step, next_step )

          procedure.id = next_step
        end

        return procedure
      end

      def build_delete_finalize( procedure, step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        step.id = 'DELETE'
        procedure.id = 'DELETE'
        procedure.done

        return procedure
      end

      def manage_delete( procedure )
        unless is_procedure?( procedure )
          return procedure
        end
        case procedure.id
          when 'DELETE-NEW'
            procedure = build_delete_new( 'DELETE-NEW-PICK-DATABASE' )
            return build_add_database_choice( procedure, procedure.steps[0], 'DELETE-NEW-PICK-DATABASE' )
          when 'DELETE-NEW-PICK-DATABASE'
            return build_add_table_choice( procedure, procedure.steps[0], 'DELETE-NEW-PICK-TABLE' )
          when 'DELETE-NEW-PICK-TABLE'
            return build_add_delete_options( procedure, procedure.steps[0], 'DELETE-NEW-WHERE' )
          when 'DELETE-NEW-WHERE'
            case procedure.steps[0].get_parameter_value( '[WHERE-CLAUSE]' )
              when 'YES'
                return build_add_where_type_choice( procedure, procedure.steps[0], 'DELETE-NEW-WHERE-TYPE' )
              else
                return build_add_where_no_use( procedure, procedure.steps[0], 'DELETE-LAST' )
            end
          when 'DELETE-NEW-WHERE-TYPE'
            case procedure.steps[0].get_parameter_value( '[WHERE-TYPE]' )
              when 'SIMPLE'
                return build_add_where_simple_options( procedure, procedure.steps[0], 'DELETE-NEW-WHERE-PICK' )
              else
                # invalid value for the where type, ignore and use nothing for the where clause
                return build_add_where_no_use( procedure, procedure.steps[0], 'DELETE-LAST' )
            end
          when 'DELETE-NEW-WHERE-PICK'
            return build_add_where_column_options( procedure, procedure.steps[0], 'DELETE-NEW-WHERE-BUILD' )
          when 'DELETE-NEW-WHERE-BUILD'
            return build_add_where_simple_use( procedure, procedure.steps[0], 'DELETE-LAST' )
          when 'DELETE-LAST'
            return build_delete_finalize( procedure, procedure.steps[0] )
          else
        end

        return procedure
      end

      def build_drop_new( next_step )
        procedure = build_skeleton( 'DROP' )
        step = build_step('DROP', 'COMPLETED', 'DROP [TYPE]', 'TERM-PROC' )

        procedure.add_step( step )
        procedure.id = next_step

        return procedure
      end

      def build_add_drop_type( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        if @options['MODELS'] == 'MULTI'
          constraint = Maadi::Procedure::ConstraintPickList.new( %w(DATABASE TABLE) )
          step.parameters.push Maadi::Procedure::Parameter.new('[DROP-TYPE]', constraint )
        else
          constraint = Maadi::Procedure::ConstraintPickList.new( %w(TABLE) )
          step.parameters.push Maadi::Procedure::Parameter.new('[DROP-TYPE]', constraint )
        end

        procedure.id = next_step
        return procedure
      end

      def build_set_drop_database_command( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        step.command = 'DROP DATABASE [DATABASE-NAME]'

        constraint = Maadi::Procedure::ConstraintPickList.new( databases() )
        step.parameters.push Maadi::Procedure::Parameter.new('[DATABASE-NAME]', constraint )

        procedure.id = next_step
        return procedure
      end

      def build_set_drop_table_command( procedure, step, next_step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        step.command = 'DROP TABLE [TABLE-NAME]'

        #constraint = Maadi::Procedure::ConstraintPickList.new( tables('HiVAT') )
        #step.parameters.push Maadi::Procedure::Parameter.new('[TABLE-NAME]', constraint )

        procedure.id = next_step
        return procedure
      end

      def build_drop_database_finalize( procedure, step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        step.id = 'DROP-DATABASE'
        procedure.id = 'DROP-DATABASE'
        procedure.done

        database = step.get_parameter_value( '[DATABASE-NAME]' )
        if database != ''
          delete_database( database )
        end

        return procedure
      end

      def build_drop_table_finalize( procedure, step )
        unless is_procedure?( procedure ) and is_step?( step )
          return procedure
        end

        step.id = 'DROP-TABLE'
        procedure.id = 'DROP-TABLE'
        procedure.done

        table = step.get_parameter_value( '[TABLE-NAME]' )
        if table != ''
          delete_table_from_active( table )
        end

        return procedure
      end

      def manage_drop( procedure )
        unless is_procedure?( procedure )
          return procedure
        end

        case procedure.id
          when 'DROP-NEW'
            procedure = build_drop_new( 'DROP-NEW-NEXT' )
            return build_add_drop_type( procedure, procedure.steps[0], 'DROP-NEW-NEXT' )
          when 'DROP-NEW-NEXT'
            case procedure.steps[0].get_parameter_value( '[DROP-TYPE]' )
              when 'DATABASE'
                return build_set_drop_database_command( procedure, procedure.steps[0], 'DROP-DATABASE-LAST' )
              when 'TABLE'
                return build_set_drop_table_command( procedure, procedure.steps[0], 'DROP-TABLE-PICK-DATABASE' )
              else
                return procedure
            end
          when 'DROP-DATABASE-LAST'
            return build_drop_database_finalize( procedure, procedure.steps[0] )
          when 'DROP-TABLE-PICK-DATABASE'
            return build_add_database_choice( procedure, procedure.steps[0], 'DROP-TABLE-PICK-TABLE' )
          when 'DROP-TABLE-PICK-TABLE'
            return build_add_table_choice( procedure, procedure.steps[0], 'DROP-TABLE-LAST' )
          when 'DROP-TABLE-LAST'
            return build_drop_table_finalize( procedure, procedure.steps[0] )
          else
        end

        return procedure
      end

      # teardown the object if any database connections, files, etc. are open.
      def teardown

        super
      end
    end
  end
end