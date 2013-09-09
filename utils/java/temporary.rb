class Temporary
  require 'open3'
  #How to execute a command from the command line

  #First, get the name of the file
  @fileName = 'bsh-2.0b4.jar'

  #run the program
  @commandName = "java -cp \"C:/Users/Mr. Fluffy Pants/RubymineProjects/maadi-ads/utils/java/bsh-2.0b4.jar\" bsh.Interpreter"
  @outputCatcher = '---12345---'


  stdin, stdout, stderr = Open3.popen3(@commandName)
  @commandExec  = "Stack stack = new Stack();\n System.out.println(\"Stack size: \" + stack.size());\n stack.add(1);\n System.out.println(\"Stack size: \" + stack.size());\n"
  p 'Execute program'
  stdin.print( @commandExec)
  stdin.print("System.out.println(\"" + @outputCatcher +  "\");\n")
  stdin.print("System.err.println(\"" + @outputCatcher +  "\");\n")
  stdin.flush()


  p 'Print Standard Output'
  @output = stdout.readline;

  while !@output.include?(@outputCatcher)
    p @output
    @output = stdout.readline;
  end

  p 'Print Standard Error'
  @output = stderr.readline;

  while !@output.include?(@outputCatcher)
    p @output
    @output = stderr.readline;
  end

  #Try again


  p 'Execute program'
  #Write Execution program
  @commandExec  = "stack.add(2);\n System.out.println(\"Stack size: \" + stack.size());\n"
  stdin.print( @commandExec)
  stdin.print("System.out.println(\"" + @outputCatcher +  "\");\n")
  stdin.print("System.err.println(\"" + @outputCatcher +  "\");\n")
  stdin.flush()


  p 'Print Standard Output'
  @output = stdout.readline;

  while !@output.include?(@outputCatcher)
    p @output
    @output = stdout.readline;
  end

  p 'Print Standard Error'
  @output = stderr.readline;

  while !@output.include?(@outputCatcher)
    p @output
    @output = stderr.readline;
  end


end