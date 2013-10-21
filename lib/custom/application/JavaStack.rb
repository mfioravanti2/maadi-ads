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
require_relative 'interfaces/BSHApplication'
require_relative '../../core/helpers'
require 'open3'

module Maadi
  module Application
    class JavaStack < BSHApplication

      #The constructor. Sets up default values and confirms that the BSH interpreter exists
      def initialize
        super('JavaStack')

        #Current user information
        @options['STACKCLASSPATH'] = 'stack'
        @options['STACKNAME'] = 'stack' + @instance_name
        @options['CLASSNAME'] = 'CustomStack'

        @rStack = nil
      end

      #Returns the supported domains.
      def supported_domains
        return %w(ADS-STACK ADS-AXIOMATIC-STACK ALGEBRAICADS-STACK)
      end

      #Returns true if the step id is "Step" and is the correct type of step for a Stack.
      #False otherwise
      def supports_step?(step)
        if Maadi::Procedure::Step.is_step?( step )
          return %w(PUSH POP SIZE ATINDEX NULCONSTRUCT NONNULCONSTRUCT DETAILS).include?( step.id )
        end

        return false
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
                lType = 'TEXT'
                #rValue is the item that is not modified during an operation
                rValue = -1
                rType = 'TEXT'
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
                        lType = 'INTEGER'

                        bSuccess = true
                        bError = false
                      else
                        #Error:  the stack was not instantiated!
                        lValue = rValue = 'PUSH Failed, ' + @options['CLASSNAME'] + ' not instantiated'
                        lType = rType = 'TEXT'

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

                        if cmdResultsArray.at(2).to_i == 0
                          lValue = rValue = 'POP Failed, Stack is empty'
                          lType = rType = 'TEXT'

                          bSuccess = false
                          bError = true
                        else
                          #Run the operation normally: Setup the operation string and parse for results.
                          operationString = "System.out.println(" + @options['STACKNAME'] + ".pop());\n"
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
                      if @rStack != nil
                        operationString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"

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

                      if @rStack != nil && index != ''
                        #Need to check for size first
                        lValueOPString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"


                        #First run the operation to check the size. If the size is zero, then flag error and exit
                        cmdResultsArray = runOperation('', lValueOPString, '')

                        #get the size
                        tempSize = cmdResultsArray.at(2).to_i

                        if  tempSize == 0

                          #If the stack is empty, then there is no point to index something.
                          lValue = rValue = 'ATINDEX Failed, Stack is empty'
                          lType = rType = 'TEXT'

                          bSuccess = false
                          bError = true
                        elsif  index >= tempSize

                          # Check to make sure the index is within bounds of the size.
                          lValue = rValue = 'ATINDEX Failed, requested index is larger than stack size'
                          lType = rType = 'TEXT'

                          bSuccess = false
                          bError = true
                        else

                          #Everything is good, continue onward.
                          rValueOPString = "System.out.println(" + @options['STACKNAME'] + ".atIndex(" + stringIndex + "));\n"
                          lValueOPString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"

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

                      operationString = @options['CLASSNAME'] +  " " + @options['STACKNAME'] + " = new " + @options['CLASSNAME'] + "();\n"
                      lValueOPString = "System.out.println(" + @options['STACKNAME'] + ".size());\n"

                      #Run the operation
                      cmdResultsArray = runOperation(operationString, lValueOPString, '')

                      #Set lValue - index 0 (STDOUT)
                      rValue = lValue = cmdResultsArray.at(2)
                      rType = lType = 'INTEGER'

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
                      rValue = lValue = cmdResultsArray.at(2)
                      rType = lType = 'INTEGER'

                      bSuccess = true
                      bError = false

                      @rStack = true
                    when 'DETAILS'

                      if @rStack != nil
                        operationString = ''
                        lValueOPString = "System.out.println(" + @options['STACKNAME'] + ");\n"

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