# Author : Scott Hull (shull2013@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 09/05/2013
# File   : JavaStack.rb
#
# Summary: An Application class extention that interfaces with BeanShell (BSH)
#          in order to utilize and maintain a JVM while performing operations
#          on an implementation of a Stack.

require_relative 'factory'
require_relative '../../core/helpers'
require 'open3'

module Maadi
  module Application
    class JavaStack < Application

      #The constructor. Sets up default values and confirms that the BSH interpreter exists
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
        @options['DEFAULTCAPACITY'] = 10
        @options['COMMANDNAME'] = "java -cp \"" + @options['BSHPATH']  + "\" bsh.Interpreter"
        @options['OUTPUTCATCH'] = '---12345---'
        @jStdIn = nil
        @jStdOut = nil
        @jStdErr = nil
        @db = nil;        #Instead of representing a database, this represents if the path exists for BSH
        @rStack = nil;    #Instead of representing an instantiated object, represents if the stack has been constructed
      end

      # Alter the Maadi::Generic.set_option, some paths have dependencies that need to
      # be updated as a result of the ROOTPATH being updated.
      def set_option( option, value )
        if option == 'ROOTPATH'
          @options['ROOTPATH'] = File.expand_path(value)
          @options['BSHPATH'] = File.expand_path(@options['ROOTPATH'] + '/bsh-2.0b4.jar')
          @options['COMMANDNAME'] = "java -cp \"" + @options['BSHPATH']  + "\" bsh.Interpreter"
        else
          super( option, value )
        end
      end


      #Prepares the bsh interpreter by opening a connection to stdout, stderr, and stdin.  Strips all formatting and
      #adds the classpath to the specified folder titled "stuff".
      def prepare

        #Confirm that bsh exists.  Use the class variable @db to specify if the BSHPath exists
        if File.exists?(@options['BSHPATH']) == true
          Maadi::post_message(:Info, 'JavaStack ->initialize:  FilePath is located')
          @db = 1 #Make it not nil
        else
          Maadi::post_message(:Info, 'JavaStack: Fatal Error - unable to locate the bsh path!')
          return false
        end

        begin
          #Create execute statement
          @jStdIn, @jStdOut, @jStdErr = Open3.popen3("java -cp \"" + @options['BSHPATH'] + "\" bsh.Interpreter")

          #Add Class Path to MyStack
          classPath = "addClassPath(\"" + @options['ROOTPATH'] + "/stuff\");\n"

          #Execute class path and flush the pipe
          @jStdIn.print classPath

          #Print output catchers
          @jStdIn.print("System.out.println(\"" + @options['OUTPUTCATCH'] +  "\");\n")
          @jStdIn.print("System.err.println(\"" + @options['OUTPUTCATCH'] +  "\");\n")
          @jStdIn.flush()

          #Print STDERR and STDOUT to screen to check for errors
          output1 = @jStdOut.readline;

          while !output1.include?(@options['OUTPUTCATCH'])
            output1 = @jStdOut.readline;
          end

          #Get standard error
          output1 = @jStdErr.readline;

          while !output1.include?(@options['OUTPUTCATCH'])
            output1 = @jStdErr.readline;
          end

        rescue => e
          Maadi::post_message(:Warn, "Application (#{@type}:#{@instance_name}) was unable to initialize (#{e.message}).")
        end

        super
      end


      #Returns the supported domains.  In this case, ADS-STACK.
      def supported_domains
        return %w(ADS-STACK)
      end


      #Returns true if the step id is "Step" and is the correct type of step for a Stack.
      #False otherwise
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

      #Runs the code by printing the operationalString to STDIN, flushes the pipe, and gathers results
      #from STDOUT and STDERR
      #
      #Params:
      #operationaString - A string that represents a full execution statement to be used within the BSH interpreter
      #
      def runCode (operationalString)

        #First, run the code with operationalString
        @jStdIn.print (operationalString)
        @jStdIn.print ("System.out.println(\"" + @options['OUTPUTCATCH'] + "\");\n")
        @jStdIn.print ("System.err.println(\"" + @options['OUTPUTCATCH'] + "\");\n")
        @jStdIn.flush()

        #Gather results from both STDIN and STDOUT
        output1 = ''
        stdOut = ''
        stdErr = ''

        #Reads Standard out and std error

        #Reads standard out until the string catch is called
        output1 = @jStdOut.readline;

        while !output1.include? (@options['OUTPUTCATCH'])
          stdOut+= output1
          output1 = @jStdOut.readline;
        end

        #Reads standard error until the string catch is called
        output1 = @jStdErr.readline;

        while !output1.include? (@options['OUTPUTCATCH'])
          stdErr+= output1
          output1 = @jStdErr.readline;
        end

        #Create the array and add Standard Out and Standard Error
        resultsArray = Array.new()
        #Replace the bsh % with empty string because we do not want them in output
        #Strip (remove) BSH characters from strings, as these are not needed
        stdOut = stdOut.gsub("bsh %", "")
        stdErr = stdErr.gsub("bsh %", "")

        #Strip (remove) new lines and excess characters (whitepsace) as these are not needed
        resultsArray.push(stdOut.gsub("\n", "").strip())
        resultsArray.push(stdErr.gsub("\n", "").strip())

        #Return a size 2 array
        return resultsArray

      end

      #Runs the operational String, then runs lValueOPString and rValueOPString.  Returns
      #6 Strings. These strings are in pairs for STDIN and STDOUT, striped of the bsh%
      # and linked in the corresponding indecies based on the command passed.
      #
      #Params:
      #operationaString, lValueOPString, rValueOPString - A string that represents a full execution statement to be used within the BSH interpreter
      #
      def runOperation (operationalString, lValueOPString, rValueOPString)

        #Create an array
        cmdResultsArray = Array.new()

        #Run the first operation
        if operationalString != ''

          #Run the code
          resultsArray = runCode(operationalString)

          #Add contents
          cmdResultsArray.push(resultsArray.at(0))
          cmdResultsArray.push(resultsArray.at(1))
        else

          #Push empty results
          cmdResultsArray.push('')
          cmdResultsArray.push('')

        end

        #Run the second operation
        if lValueOPString != ''

          #Run the code
          resultsArray = runCode(lValueOPString)

          #Add contents
          cmdResultsArray.push(resultsArray.at(0))
          cmdResultsArray.push(resultsArray.at(1))

        else

          #Push empty results
          cmdResultsArray.push('')
          cmdResultsArray.push('')

        end

        #Run the third operation
        if rValueOPString != ''

          #Run the code
          resultsArray = runCode(rValueOPString)

          #Add contents
          cmdResultsArray.push(resultsArray.at(0))
          cmdResultsArray.push(resultsArray.at(1))

        else

          #Push empty results
          cmdResultsArray.push('')
          cmdResultsArray.push('')

        end


        return cmdResultsArray

      end


      #Executes a procedure (a collection of steps) that are valid to the
      # execution of a ADS-STACK domain.
      #
      #Parameters:
      #test_id - an identification of a collection of steps
      #procedure - The procedure to execute
      #
      def execute(test_id, procedure)
        results = Maadi::Procedure::Results.new(test_id.to_i, 0, "#{@type}:#{@instance_name}", nil)
        if procedure.is_a? ( ::Maadi::Procedure::Procedure)
          results.proc_id = procedure.id

          procedure.steps.each do |step|
            if step.target == 'application'
              if supports_step? (step)

                #lValue is the item that is modified (usually the stack)
                lValue = -1
                #rValue is the item that is not modified during an operation
                rValue = -1
                bSuccess = false
                bError = false
                #The normal operation call
                operationString = ''
                #Used when a status update is needed, like the size of the stack after a push
                lValueOPString = ''
                rValueOPString = ''

                begin
                  case step.id

                    #Case for when a push is called
                    when 'PUSH'

                      #Get the value to add to the push
                      rValue = step.get_parameter_value('[RVALUE]')

                      #If the stack is instantiated, then work
                      if @rStack != nil  && rValue != ''

                        operationString = @options['STACKNAME'] + ".push(" + rValue + ");\n"
                        lValueOPString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"

                        #Run the operation
                        cmdResultsArray = runOperation(operationString, lValueOPString, '')

                        #Set lValue - index 2 (STDOUT)
                        lValue = cmdResultsArray.at(2)

                        bSuccess = true
                        bError = false
                      else

                        #Error:  the stack was not instantiated!
                        lValue = rValue = 'PUSH Failed, ' + @options['CLASSNAME'] + ' not instantiated'
                        bSuccess = false
                        bError = true
                      end

                    when 'POP'
                      #Make sure the stack is initialized.
                      if @rStack != nil
                        #Need to check for size first
                        lValueOPString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"


                        #First run the operation to check the size. If the size is zero, then flag error and exit
                        cmdResultsArray = runOperation('', lValueOPString, '')

                        if cmdResultsArray.at(2).include?(' 0')
                          lValue = rValue = 'POP Failed, Stack is empty'
                          bSuccess = false
                          bError = true
                        else
                          #Run the operation normally: Setup the operation string and parse for results.
                          operationString = "System.out.println(" + @options['STACKNAME'] + ".pop());\n"
                          #Run the operation
                          cmdResultsArray = runOperation(operationString, lValueOPString, '')

                          #Set lValue - index 0 (STDOUT)
                          lValue = cmdResultsArray.at(0)

                          #Set the rValue - index 2 (STDOUT)
                          rValue = cmdResultsArray.at(2)

                          bSuccess = true
                          bError = false
                        end


                      else
                        lValue = rValue = 'POP Failed, ' + @options['CLASSNAME'] + ' not instantiated'
                        bSuccess = false
                        bError = true
                      end

                    when 'SIZE'
                      if @rStack != nil

                        operationString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"

                        #Run the operation
                        cmdResultsArray = runOperation(operationString, '', '')

                        #Set lValue - index 0 (STDOUT)
                        lValue = cmdResultsArray.at(0)

                        bSuccess = true
                        bError = false
                      else
                        lValue = rValue = 'SIZE Failed, ' + @options['CLASSNAME'] + ' not instantiated'
                        bSuccess = false
                        bError = true
                      end
                    when 'ATINDEX'

                      #Get the index value
                      index = step.get_parameter_value('[INDEX]')

                      if @rStack != nil && index != ''
                        #Need to check for size first
                        lValueOPString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"


                        #First run the operation to check the size. If the size is zero, then flag error and exit
                        cmdResultsArray = runOperation('', lValueOPString, '')

                        if cmdResultsArray.at(2).include?(' 0')

                          #If the stack is empty, then there is no point to index something.
                          lValue = rValue = 'ATINDEX Failed, Stack is empty'
                          bSuccess = false
                          bError = true
                        elsif  index >= cmdResultsArray.at(2)

                          # Check to make sure the index is within bounds of the size.
                          lValue = rValue = 'ATINDEX Failed, requested index is larger than stack size'
                          bSuccess = false
                          bError = true
                        else

                          #Everything is good, continue onward.
                          rValueOPString = "System.out.println(" + @options['STACKNAME'] + ".atIndex(" + index + "));\n"
                          lValueOPString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"

                          #Run the operation
                          cmdResultsArray = runOperation('', lValueOPString, rValueOPString)

                          #Set lValue - index 2 (STDOUT)
                          lValue = cmdResultsArray.at(2)

                          #Set rValue = index 4 (STDOUT)
                          rValue = cmdResultsArray.at(4)
                        end

                      else
                        lValue = rValue = 'ATINDEX Failed, ' + @options['CLASSNAME'] + ' not instantiated'
                        bSuccess = false
                        bError = true
                      end

                    when 'NULCONSTRUCT'

                      operationString = @options['CLASSNAME'] +  " " + @options['STACKNAME'] + " = new " + @options['CLASSNAME'] + "();\n"
                      lValueOPString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"

                      #Run the operation
                      cmdResultsArray = runOperation(operationString, lValueOPString, '')

                      #Set lValue - index 0 (STDOUT)
                      lValue = cmdResultsArray.at(2)

                      bSuccess = true
                      bError = false

                      #We use rStack as an indication that the stack was created. Otherwise, pops on an uninitialized stack will occur.
                      #this is to help prevent errors.
                      @rStack = true

                    when 'NONNULCONSTRUCT'

                      # CURRENTLY DOES NOT TAKE A SIZE
                      operationString = @options['CLASSNAME'] +  " " + @options['STACKNAME'] + " = new " + @options['CLASSNAME'] + "();\n"
                      lValueOPString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"

                      #Run the operation
                      cmdResultsArray = runOperation(operationString, lValueOPString, '')

                      #Set lValue - index 0 (STDOUT)
                      lValue = cmdResultsArray.at(2)

                      bSuccess = true
                      bError = false

                      @rStack = true


                  end

                  #Print some meaningful information
                  Maadi::post_message(:Info, "Operation String: ' #{operationString.to_s}",3)
                  if lValue != -1
                    Maadi::post_message(:Info, " lValueOPString: ' #{lValueOPString.to_s}",3)
                    Maadi::post_message(:Info, " lValue: ' #{lValue.to_s}",3)
                  end
                  if rValue != -1
                    Maadi::post_message(:Info, " rValueOPString: ' #{rValueOPString.to_s}",3)
                    Maadi::post_message(:Info, " rValue: ' #{rValue.to_s}",3)
                  end


                  #Handle the results
                  case step.look_for
                    when 'NORECORD'
                    when 'LVALUE'
                      results.add_result( Maadi::Procedure::Result.new( step, lValue.to_s, 'TEXT', ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                    when 'RVALUE'
                      results.add_result( Maadi::Procedure::Result.new( step, rValue.to_s, 'TEXT', ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                    when 'CHANGES'
                      results.add_result( Maadi::Procedure::Result.new( step, '', 'TEXT', ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                    when 'COMPLETED'
                      results.add_result( Maadi::Procedure::Result.new( step, '', 'TEXT', ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
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




        #When finished, return the results
        return results
      end

      #Close the pipes.
      def teardown
        if @db != nil
          @jStdIn.close()
          @jStdOut.close()
          @jStdErr.close()
        end

        super
      end
    end
  end
end