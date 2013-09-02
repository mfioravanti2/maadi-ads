
require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Application
    class JavaStack < Application

      def initialize
        super('JavaStack')

        #Current user information
        @options['WORKDIR'] = Dir.pwd;

        #Set up our paths
        @options['BSHPATH'] = @options['WORKDIR'] + '/utils/java'
        @options['STACKCLASSPATH'] = 'stack'
        @options['STACKNAME'] = 'stack' + @instance_name
        @options['ISCONSTRUCTED'] = 'false'
        @options['CLASSNAME']  = 'MyStack'
        @options['DEFAULTCAPACITY'] = 10;
        @db = nil;

        #Confirm that bsh exists
        if File.directory(@options['BSHPATH'] + 'bsh-2.0b4.jar') == true
          @db = 1 #Make it not nil
        end

        #Start up bsh?


      end

      def prepare
        begin
          #Create execute statement
          executeStatement = 'java - jar'
        rescue => e
          Maadi::post_message(:Warn, "Application (#{@type}:#{@instance_name}) was unable to connect (#{e.message}).")

        end
      end
      def supported_domains
        return %w(ADS-STACK)
      end
      def supports_step?( step )
        if step != nil
          if step.is_a?( ::Maadi::Procedure::Step )
            case step.id
              when 'PUSH'
                return true
              when 'POP'
                return true
              when 'SIZE'
                return true
              when 'ATINDEX'
                return true
              when 'NULCONSTRUCT'
                return true
              when 'NONNULCONSTRUCT'
                return true
              else
            end
          end
        end

        return false
      end

      def execute( test_id, procedure )
        results = Maadi::Procedure::Results.new( test_id.to_i, 0, "#{@type}:#{@instance_name}", nil )
        operationString = ''
        errorHit = false
        errorString = nil
        outputString = nil

        if @db != nil
          if procedure.is_a?( ::Maadi::Procedure::Procedure )
            results.proc_id = procedure.id

            procedure.steps.each do |step|
              if step.target == execution_target
                sql_cmd = step.execute
                if supports_step?( step )
                  begin
                    case step.id
                      when 'PUSH'
                        #Need the PRIMITIVE OR STRING value
                        value = step.get_parameter_value('VALUE')
                        #If it does not exist, flag error
                        if(value == nil)
                          errorHit = true
                          errorHit = 'No value passed or value does not exist'
                        else
                          #Perfrom the push operation.  No results printed
                          operationString = @options['STACKNAME'] + '.push(' + value + ')'
                        end
                      when 'POP'
                        #Perform the pop operation and print the result of the pop.
                        operationString = 'System.out.println(' + @options['STACKNAME'] + '.pop());'
                      when 'SIZE'
                        #Perform the atIndex() operation
                        operationString = @options['STACKNAME'] + '.size();'
                      when 'ATINDEX'
                        #Need the index from the parameter value.
                        index = step.get_parameter_value('INDEX')
                        #If it does not exist, flag error
                        if(index == nil)
                          errorHit = true
                          errorHit = 'No index passed or index does not exist'
                        else
                          #Perform the atIndex() operation
                          operationString = @options['STACKNAME'] + '.atIndex(' + index + ');'
                        end
                      when 'NULCONSTRUCT'
                        #Perfrom the nullary constructor
                        operationString = @options['CLASSNAME'] + ' ' + @options['STACKNAME'] + ' = new ' + @options['CLASSNAME'] + '();'
                      when 'NONNULCONSTRUCT'
                        capacity = step.get_parameter_value('CAPACITY')
                        if(capacity == nil)
                          capacity = @options['DEFAULTCAPACITY']
                        end
                        #Use the constructor, but pass a parameter called capacity.
                        operationString = @options['CLASSNAME'] + ' ' + @options['STACKNAME'] + ' = new ' + @options['CLASSNAME'] + '(' + capacity +');'

                      else
                    end

                    #run the program and execute

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