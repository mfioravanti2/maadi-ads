require_relative 'factory'
require_relative '../../core/helpers'
require 'open3'

module Maadi
  module Application
    class JavaStack < Application

      def initialize
        super('JavaStack')

        #Current user information

        #Set up our paths
        @options['ROOTPATH'] = File.expand_path('~/RubymineProjects/maadi-ads/utils/java')
        @options['BSHPATH'] = File.expand_path(@options['ROOTPATH'] + '/bsh-2.0b4.jar')
        @options['STACKCLASSPATH'] = 'stack'
        @options['STACKNAME'] = 'stack' + @instance_name
        @options['ISCONSTRUCTED'] = 'false'
        @options['CLASSNAME'] = 'MyStack'
        @options['DEFAULTCAPACITY'] = 10;
        @options['COMMANDNAME'] = "java -cp \"" + @options['BSHPATH']  + "\" bsh.Interpreter"
        @options['OUTPUTCATCH'] = '---12345---'
        @options['STDIN'] = nil
        @options['STDOUT'] = nil
        @options['STDERR'] = nil
        @db = nil;

        #Confirm that bsh exists
        if File.exists?(@options['BSHPATH']) == true
          p 'JavaStack ->initialize:  FilePath is located'
          @db = 1 #Make it not nil
        else
          p 'JavaStack: Fatal Error - unable to locate the bsh path!'
        end


      end

      def prepare

        begin
          p 'JavaStack->prepare: Trying to connect to the pipe: ' + @options['COMMANDNAME']
          #Create execute statement
          @options['STDIN'], @options['STDOUT'], @options['STDERR'] = Open3.popen3("java -cp \"C:/Users/Mr. Fluffy Pants/RubymineProjects/maadi-ads/utils/java/bsh-2.0b4.jar\" bsh.Interpreter")
          p 'JavaStack->prepare:  Connection successful'

          #Add Class Path to MyStack
          classPath = "addClassPath(\"" + @options['ROOTPATH'] + "/stuff\");\n"

          p 'JavaStack->prepare: Trying to execute the classpath'
          p 'JavaStack->prepare->classPath: ' + classPath;
          #Execute class path and flush the pipe
          @options['STDIN'].print classPath

          #Print output catchers
          @options['STDIN'].print("System.out.println(\"" + @options['OUTPUTCATCH'] +  "\");\n")
          @options['STDIN'].print("System.err.println(\"" + @options['OUTPUTCATCH'] +  "\");\n")
          @options['STDIN'].flush()

          #Print STDERR and STDOUT to screen to check for errors
          p 'JavaStack->prepare: Printing STDOUT'
          output1 = @options['STDOUT'].readline;

          while !output1.include?(@options['OUTPUTCATCH'])
            p output1
            output1 = @options['STDOUT'].readline;
          end

          p 'JavaStack->prepare: Printing STDERR'
          output1 = @options['STDERR'].readline;

          while !output1.include?(@options['OUTPUTCATCH'])
            p output1
            output1 = @options['STDERR'].readline;
          end
          p 'JavaStack->prepare: Preparations are complete.'
        rescue => e
          Maadi::post_message(:Warn, "Application (#{@type}:#{@instance_name}) was unable to initialize (#{e.message}).")
        end

      end

      def supported_domains
        return %w(ADS-STACK)
      end

      def supports_step?(step)
        if step != nil
          if step.is_a?(::Maadi::Procedure::Step)
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

      def execute(test_id, procedure)
        results = Maadi::Procedure::Results.new(test_id.to_i, 0, "#{@type}:#{@instance_name}", nil)
        operationString = ''
        errorHit = false
        errorString = nil
        outputString = nil

        if @db != nil
          if procedure.is_a?(::Maadi::Procedure::Procedure)
            results.proc_id = procedure.id

            procedure.steps.each do |step|
              if step.target == execution_target
                sql_cmd = step.execute
                if supports_step?(step)
                  begin
                    case step.id
                      when 'PUSH'
                        #Need the PRIMITIVE OR STRING value
                        value = step.get_parameter_value('VALUE')
                        #If it does not exist, flag error
                        if (value == nil)
                          errorHit = true
                          errorHit = 'No value passed or value does not exist'
                        else
                          #Perfrom the push operation.  No results printed
                          operationString = @options['STACKNAME'] + ".push(" + value + ");\n"
                        end
                      when 'POP'
                        #Perform the pop operation and print the result of the pop.
                        operationString = "System.out.println(" + @options['STACKNAME'] + ".pop());\n"
                      when 'SIZE'
                        #Perform the atIndex() operation
                        operationString = @options['STACKNAME'] + ".size();\n"
                      when 'ATINDEX'
                        #Need the index from the parameter value.
                        index = step.get_parameter_value('INDEX')
                        #If it does not exist, flag error
                        if (index == nil)
                          errorHit = true
                          errorHit = 'No index passed or index does not exist'
                        else
                          #Perform the atIndex() operation
                          operationString = @options['STACKNAME'] + ".atIndex(" + index + ");\n"
                        end
                      when 'NULCONSTRUCT'
                        #Perfrom the nullary constructor
                        operationString = @options['CLASSNAME'] + " " + @options['STACKNAME'] + " = new " + @options['CLASSNAME'] + "();\n"
                      when 'NONNULCONSTRUCT'
                        capacity = step.get_parameter_value('CAPACITY')
                        if (capacity == nil)
                          capacity = @options['DEFAULTCAPACITY']
                        end
                        #Use the constructor, but pass a parameter called capacity.
                        operationString = @options['CLASSNAME'] + " " + @options['STACKNAME'] + " = new " + @options['CLASSNAME'] + "(" + capacity +");\n"

                      else
                    end

                    #run the program and execute
                    p 'Execute program'
                    @options['STDIN'].print( operationString)
                    @options['STDIN'].print("System.out.println(\"" + @options['OUTPUTCATCH'] +  "\");\n")
                    @options['STDIN'].print("System.err.println(\"" + @options['OUTPUTCATCH'] +  "\");\n")
                    @options['STDIN'].flush()
                    case step.look_for
                      when 'NORECORD'
                      when 'CHANGES'
                        results.add_result(Maadi::Procedure::Result.new(step, @db.affected_rows, 'TEXT', 'SUCCESS'))
                      when 'COMPLETED'
                        results.add_result(Maadi::Procedure::Result.new(step, '', 'TEXT', 'SUCCESS'))
                      else
                        results.add_result(Maadi::Procedure::Result.new(step, '', 'TEXT', 'UNKNOWN'))
                    end
                  rescue => e
                    Maadi::post_message(:Warn, "Application (#{@type}:#{@instance_name}) encountered an error (#{e.message}).")
                    results.add_result(Maadi::Procedure::Result.new(step, e.message, 'TEXT', 'EXCEPTION'))
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
          @options['STDIN'].close()
          @options['STDOUT'].close()
          @options['STDERR'].close()
        end

        super
      end
    end
  end
end