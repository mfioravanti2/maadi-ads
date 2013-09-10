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
        @rStack = nil;

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

      #Runs the code
      def runCode (operationalString)

        p' In the run code for : ' + operationalString
        #First, run the code with operationalString
        @options['STDIN'].print (operationalString)
        @options['STDIN'].print ("System.out.println(\"" + @options['OUTPUTCATCH'] + "\");\n")
        @options['STDIN'].print ("System.err.println(\"" + @options['OUTPUTCATCH'] + "\");\n")
        @options['STDIN'].flush()

        #Gather results from both STDIN and STDOUT
        output1 = ''
        stdOut = ''
        stdErr = ''

        #Reads Standard out and std error

        #Reads standard out
        output1 = @options['STDOUT'].readline;

        while !output1.include? (@options['OUTPUTCATCH'])
          stdOut+= output1
          output1 = @options['STDOUT'].readline;
        end

        #Reads standard error
        output1 = @options['STDERR'].readline;

        while !output1.include? (@options['OUTPUTCATCH'])
          stdErr+= output1
          output1 = @options['STDERR'].readline;
        end

        #Create the array and add Standard Out and Standard Error
        stringArray = Array.new()
        #Replace the bsh % with empty string
        p 'Before strip, printing STDOUT for ' + operationalString + " : " + stdOut
        p 'Before strip, printing STDERR for ' + operationalString + " : " + stdErr

        stringArray.push(stdOut.sub("bsh %", ""))
        stringArray.push(stdOut.sub("bsh %", ""))

        p 'After strip, printing STDOUT for ' + operationalString + " : " + stringArray.at(0)
        p 'After strip, printing STDERR for ' + operationalString + " : " + stringArray.at(1)

        #Return a size 2 array
        return stringArray

      end

      #Runs the operational String, then runs lValueOPString and rValueOPString.  Returns
      #6 Strings. These strings are in pairs for STDIN and STDOUT, striped of the bsh%
      def runOperation (operationalString, lValueOPString, rValueOPString)

        #Create an array
        stringArray = Array.new()

        #Run the first operation
        if operationalString != ''

          #Run the code
          tempArray = runCode(operationalString)

          #Add contents
          stringArray.push(tempArray.at(0))
          stringArray.push(tempArray.at(1))

        end

        #Run the first operation
        if lValueOPString != ''

          #Run the code
          tempArray = runCode(lValueOPString)

          #Add contents
          stringArray.push(tempArray.at(0))
          stringArray.push(tempArray.at(1))

        end

        #Run the first operation
        if rValueOPString != ''

          #Run the code
          tempArray = runCode(rValueOPString)

          #Add contents
          stringArray.push(tempArray.at(0))
          stringArray.push(tempArray.at(1))

        end


        return stringArray

      end



      def execute(test_id, procedure)
        results = Maadi::Procedure::Results.new(test_id.to_i, 0, "#{@type}:#{@instance_name}", nil)
        p 'JavaStack->execute: In Execute'
        if procedure.is_a? ( ::Maadi::Procedure::Procedure)
          results.proc_id = procedure.id
            p 'JavaStack procedure identified?'

          procedure.steps.each do |step|
            p 'In here'
            if step.target == ''
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
                      rValue = step.get_parameter_valie('[RVALUE]')

                      #If the stack is instantiated, then work
                      if(@rStack != nil)
                        operationString = @options['STACKNAME'] + ".push(" + rValue + ");\n"
                        lValueOPString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"

                        #Run the operation
                        stringArray = runOperation(operationString, lValueOPString, '')

                        #Set lValue - index 2 (STDOUT)
                        lValue = stringArray.at(2)

                        bSuccess = true
                        bError = false
                      else
                        lValue = rValue = 'PUSH Failed, ' + @options['CLASSNAME'] + ' not instantiated'
                        bSuccess = false
                        bError = true
                      end

                    when 'POP'
                      #Make sure the stack is initialized.
                      if @rStack != nil
                        #Need to check for size, but this is not available with this interface
                        operationString = "System.out.println(" + @options['STACKNAME'] + ".pop());\n"
                        lValueOPString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"

                        #Run the operation
                        stringArray = runOperation(operationString, lValueOPString, '')

                        #Set lValue - index 0 (STDOUT)
                        lValue = stringArray.at(0)

                        #Set the rValue - index 2 (STDOUT)
                        rValue = stringArray.at(2)

                        bSuccess = true
                        bError = false
                      else
                        lValue = rValue = 'POP Failed, ' + @options['CLASSNAME'] + ' not instantiated'
                        bSuccess = false
                        bError = true
                      end

                    when 'SIZE'
                      if @rStack != nil

                        operationString = @options['STACKNAME'] + ".size();\n"

                        #Run the operation
                        stringArray = runOperation(operationString, '', '')

                        #Set lValue - index 0 (STDOUT)
                        lValue = stringArray.at(0)

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

                      if @rStack != nil

                        rValueOPString = "System.out.println(" + @options['STACKNAME'] + ".atIndex(" + index + "));\n"
                        lValueOPString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"

                        #Run the operation
                        stringArray = runOperation('', lValueOPString, rValueOPString)

                        #Set lValue - index 2 (STDOUT)
                        lValue = stringArray.at(2)

                        #Set rValue = index 4 (STDOUT)
                        rValue = stringArray.at(4)

                      else
                        lValue = rValue = 'ATINDEX Failed, ' + @options['CLASSNAME'] + ' not instantiated'
                        bSuccess = false
                        bError = true
                      end

                    when 'NULCONSTRUCT'
                      p 'JavaStack->Execute: NULCONSTRUCT CALLED'
                      operationString = @options['CLASSNAME'] +  " " + @options['STACKNAME'] + " = new " + @options['CLASSNAME'] + "();\n"
                      lValueOPString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"

                      #Run the operation
                      stringArray = runOperation(operationString, lValueOPString, '')

                      #Set lValue - index 0 (STDOUT)
                      lValue = stringArray.at(0)

                      bSuccess = true
                      bError = false

                      @rStack = true
                    when 'NONNULCONSTRUCT'
                      # CURRENTLY DOES NOT TAKE A SIZE
                      operationString = @options['CLASSNAME'] +  " " + @options['STACKNAME'] + " = new " + @options['CLASSNAME'] + "();\n"
                      lValueOPString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"

                      #Run the operation
                      stringArray = runOperation(operationString, lValueOPString, '')

                      #Set lValue - index 0 (STDOUT)
                      lValue = stringArray.at(0)

                      bSuccess = true
                      bError = false

                      @rStack = true


                  end

                  p 'Print results'
                  p 'Operational String: ' + operationString
                  if lValue != -1
                    p ' lValue: ' + lValue
                  end
                  if rValue != -1
                    p ' rValue: ' + rValue
                  end



                  #Handle the results
                  case step.look_for
                    when 'NORECORD'
                    when 'LVALUE'
                      results.add_result( Maadi::Procedure::Result.new( step, lValue.to_a, 'TEXT', ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                    when 'RVALUE'
                      results.add_result( Maadi::Procedure::Result.new( step, rValue.to_a, 'TEXT', ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
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