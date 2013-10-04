# Author : Scott Hull (shull2013@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 10/03/2013
# File   : JavaQueue.rb
#
# Summary: An Application class extension that interfaces with BeanShell (BSH)
#          in order to utilize and maintain a JVM while performing operations
#          on an implementation of a Queue.

require_relative 'factory'
require_relative '../../core/helpers'
require 'open3'

module Maadi
  module Application
    class JavaQueue < Application

      #The constructor. Sets up default values and confirms that the BSH interpreter exists
      def initialize
        super('JavaQueue')

        #Current user information

        #Set up our paths
        @options['ROOTPATH'] = File.expand_path('~/RubymineProjects/maadi-ads/utils/java')
        @options['BSHPATH'] = File.expand_path(@options['ROOTPATH'] + '/bsh-2.0b4.jar')
        @options['QUEUECLASSPATH'] = 'queue'
        @options['QUEUENAME'] = 'queue' + @instance_name
        @options['ISCONSTRUCTED'] = 'false'
        @options['CLASSNAME'] = 'LinkedList'
        @options['DEFAULTCAPACITY'] = 10
        @options['COMMANDNAME'] = "java -cp \"" + @options['BSHPATH']  + "\" bsh.Interpreter"
        @options['OUTPUTCATCH'] = '---12345---'
        @jStdIn = nil
        @jStdOut = nil
        @jStdErr = nil
        @db = nil;        #Instead of representing a database, this represents if the path exists for BSH
        @rQueue = nil;    #Instead of representing an instantiated object, represents if the queue has been constructed
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
          Maadi::post_message(:Info, "Application (#{@type}:#{@instance_name}) has valid BSH path")
          @db = 1 #Make it not nil
        else
          Maadi::post_message(:Warn, "Application (#{@type}:#{@instance_name}) BSH path is INVALID")
          return false
        end

        begin
          #Create execute statement
          @jStdIn, @jStdOut, @jStdErr = Open3.popen3("java -cp \"" + @options['BSHPATH'] + "\" bsh.Interpreter")

          #Add Class Path to Queue
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
        return %w(ADS-STACK ALGEBRAICADS-STACK)
      end


      #Returns true if the step id is "Step" and is the correct type of step for a Queue.
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
              when 'DETAILS'
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

                #lValue is the item that is modified (usually the queue)
                lValue = -1
                lType = 'TEXT'
                #rValue is the item that is not modified during an operation
                rValue = -1
                rType = 'TEXT'

                bSuccess = false
                bError = false
                #The normal operation call
                operationString = ''
                #Used when a status update is needed, like the size of the queue after a push
                lValueOPString = ''
                rValueOPString = ''

                begin
                  case step.id
                    #Case for when a push is called
                    when 'PUSH'
                      #Get the value to add to the push
                      rValue = step.get_parameter_value('[RVALUE]')

                      #If the queue is instantiated, then work
                      if @rQueue != nil  && rValue != ''
                        operationString = @options['QUEUENAME'] + ".offer(" + rValue + ");\n"
                        lValueOPString = "System.out.println(" + @options['QUEUENAME'] + ".size());\n"

                        #Run the operation
                        cmdResultsArray = runOperation(operationString, lValueOPString, '')

                        #Set lValue - index 2 (STDOUT)
                        lValue = cmdResultsArray.at(2)
                        lType = 'INTEGER'

                        bSuccess = true
                        bError = false
                      else

                        #Error:  the queue was not instantiated!
                        lValue = rValue = 'PUSH Failed, ' + @options['CLASSNAME'] + ' not instantiated'
                        lType = rType = 'TEXT'

                        bSuccess = false
                        bError = true
                      end

                    when 'POP'
                      #Make sure the queue is initialized.
                      if @rQueue != nil
                        #Need to check for size first
                        lValueOPString = "System.out.println(" + @options['QUEUENAME'] + ".size());\n"


                        #First run the operation to check the size. If the size is zero, then flag error and exit
                        cmdResultsArray = runOperation('', lValueOPString, '')

                        if cmdResultsArray.at(2).to_i == 0
                          lValue = rValue = 'POP Failed, Queue is empty'
                          lType = rType = 'TEXT'

                          bSuccess = false
                          bError = true
                        else
                          #Run the operation normally: Setup the operation string and parse for results.
                          operationString = "System.out.println(" + @options['QUEUENAME'] + ".remove());\n"
                          #Run the operation
                          cmdResultsArray = runOperation(operationString, lValueOPString, '')

                          #Set lValue - index 0 (STDOUT)
                          lValue = cmdResultsArray.at(0)
                          lType = 'INTEGER'

                          #Set the rValue - index 2 (STDOUT)
                          rValue = cmdResultsArray.at(2)
                          rType = 'INTEGER'

                          bSuccess = true
                          bError = false
                        end
                      else
                        lValue = rValue = 'POP Failed, ' + @options['CLASSNAME'] + ' not instantiated'
                        lType = rType = 'TEXT'

                        bSuccess = false
                        bError = true
                      end

                    when 'SIZE'
                      if @rQueue != nil

                        operationString = "System.out.println(" + @options['QUEUENAME'] + ".size());\n"

                        #Run the operation
                        cmdResultsArray = runOperation(operationString, '', '')

                        #Set lValue - index 0 (STDOUT)
                        lValue = cmdResultsArray.at(0)
                        lType = 'INTEGER'

                        bSuccess = true
                        bError = false
                      else
                        lValue = rValue = 'SIZE Failed, ' + @options['CLASSNAME'] + ' not instantiated'
                        lType = rType = 'TEXT'

                        bSuccess = false
                        bError = true
                      end
                    when 'ATINDEX'
                      #Get the index value
                      stringIndex = step.get_parameter_value('[INDEX]')
                      index = stringIndex.to_i

                      if @rQueue != nil && index != ''
                        #Need to check for size first
                        lValueOPString = "System.out.println(" + @options['QUEUENAME'] + ".size());\n"

                        #First run the operation to check the size. If the size is zero, then flag error and exit
                        cmdResultsArray = runOperation('', lValueOPString, '')
                        #get the size
                        tempSize = cmdResultsArray.at(2).to_i

                        if  tempSize == 0
                          #If the queue is empty, then there is no point to index something.
                          lValue = rValue = 'ATINDEX Failed, Queue is empty'
                          lType = rType = 'TEXT'

                          bSuccess = false
                          bError = true
                        elsif  index >= tempSize
                          # Check to make sure the index is within bounds of the size.
                          lValue = rValue = 'ATINDEX Failed, requested index is larger than queue size'
                          lType = rType = 'TEXT'

                          bSuccess = false
                          bError = true
                        else
                          #Everything is good, continue onward.
                          rValueOPString = "System.out.println(" + @options['QUEUENAME'] + ".get(" + stringIndex + "));\n"
                          lValueOPString = "System.out.println(" + @options['QUEUENAME'] + ".size());\n"

                          #Run the operation
                          cmdResultsArray = runOperation('', lValueOPString, rValueOPString)

                          #Set lValue - index 2 (STDOUT)
                          lValue = cmdResultsArray.at(2)
                          lType = 'INTEGER'

                          #Set rValue = index 4 (STDOUT)
                          rValue = cmdResultsArray.at(4)
                          rType = 'INTEGER'

                          bSuccess = true
                          bError = false
                        end

                      else
                        lValue = rValue = 'ATINDEX Failed, ' + @options['CLASSNAME'] + ' not instantiated'
                        lType = rType = 'TEXT'

                        bSuccess = false
                        bError = true
                      end
                    when 'NULCONSTRUCT'
                      operationString = @options['CLASSNAME'] +  " " + @options['QUEUENAME'] + " = new " + @options['CLASSNAME'] + "();\n"
                      lValueOPString = "System.out.println(" + @options['QUEUENAME'] + ".size());\n"

                      #Run the operation
                      cmdResultsArray = runOperation(operationString, lValueOPString, '')

                      #Set lValue - index 0 (STDOUT)
                      rValue = lValue = cmdResultsArray.at(2)
                      rType = lType = 'INTEGER'

                      bSuccess = true
                      bError = false

                      #We use rQueue as an indication that the queue was created. Otherwise, pops on an uninitialized queue will occur.
                      #this is to help prevent errors.
                      @rQueue = true

                    when 'NONNULCONSTRUCT'
                      # CURRENTLY DOES NOT TAKE A SIZE
                      operationString = @options['CLASSNAME'] +  " " + @options['QUEUENAME'] + " = new " + @options['CLASSNAME'] + "();\n"
                      lValueOPString = "System.out.println(" + @options['QUEUENAME'] + ".size());\n"

                      #Run the operation
                      cmdResultsArray = runOperation(operationString, lValueOPString, '')

                      #Set lValue - index 0 (STDOUT)
                      rValue = lValue = cmdResultsArray.at(2)
                      rType = lType = 'INTEGER'

                      bSuccess = true
                      bError = false

                      @rQueue = true
                    when 'DETAILS'
                      if @rQueue != nil
                        operationString = ''
                        lValueOPString = "System.out.println(" + @options['QUEUENAME'] + ");\n"

                        #Run the operation
                        cmdResultsArray = runOperation('', lValueOPString, '')

                        #Set lValue - index 0 (STDOUT)
                        lValue = cmdResultsArray.at(2)
                        lType = 'TEXT'

                        bSuccess = true
                        bError = false
                      else
                        lValue = rValue = 'DETAILS Failed, ' + @options['CLASSNAME'] + ' not instantiated'
                        lType = rType = 'TEXT'

                        bSuccess = false
                        bError = true
                      end
                  end

                  #Print some meaningful information
                  Maadi::post_message(:Info, "#{@type}:#{@instance_name} #{step.id} Operation String: ' #{operationString.to_s}",3)
                  if lValue != -1
                    Maadi::post_message(:Info, "#{@type}:#{@instance_name} #{step.id} lValueOPString: ' #{lValueOPString.to_s}",3)
                    Maadi::post_message(:Info, "#{@type}:#{@instance_name} #{step.id} lValue: ' #{lValue.to_s}",3)
                  end
                  if rValue != -1
                    Maadi::post_message(:Info, "#{@type}:#{@instance_name} #{step.id} rValueOPString: ' #{rValueOPString.to_s}",3)
                    Maadi::post_message(:Info, "#{@type}:#{@instance_name} #{step.id} rValue: ' #{rValue.to_s}",3)
                  end

                  #Handle the results
                  case step.look_for
                    when 'NORECORD'
                    when 'LVALUE'
                      results.add_result( Maadi::Procedure::Result.new( step, lValue.to_s, lType, ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                    when 'RVALUE'
                      results.add_result( Maadi::Procedure::Result.new( step, rValue.to_s, rType, ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                    when 'CHANGES'
                      results.add_result( Maadi::Procedure::Result.new( step, '', 'TEXT', ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                    when 'COMPLETED'
                      results.add_result( Maadi::Procedure::Result.new( step, '', 'TEXT', ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                    else
                      results.add_result( Maadi::Procedure::Result.new( step, step.look_for, 'TEXT', 'UNKNOWN' ))
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