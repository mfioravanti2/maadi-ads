# Author : Scott Hull (shull2013@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 10/06/2013
# File   : BSHApplication.rb
#
# Summary: An Application class extention that interfaces with BeanShell (BSH)
#          in order to utilize and maintain a JVM while performing operations
#          on a specific implementation.

require_relative '../factory'
require_relative '../../../core/helpers'
require 'open3'

module Maadi
  module Application
    class BSHApplication < Application

      #The constructor. Sets up default values and confirms that the BSH interpreter exists
      def initialize (type)

        if type == nil
          super('BSHType')
        else
          super(type)
        end

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
        @bsh = nil        #Instead of representing a database, this represents if the path exists for BSH
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

        #Confirm that bsh exists.  Use the class variable @@bsh to specify if the BSHPath exists
        if File.exists?(@options['BSHPATH'])
          Maadi::post_message(:Info, "Application (#{@type}:#{@instance_name}) has valid BSH path")
          @bsh = 1 #Make it not nil
        else
          Maadi::post_message(:Warn, "Application (#{@type}:#{@instance_name}) BSH path is INVALID")
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

      #Close the pipes.
      def teardown
        if @bsh != nil
          @jStdIn.close()
          @jStdOut.close()
          @jStdErr.close()
        end

        super
      end
    end
  end
end