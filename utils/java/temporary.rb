class Temporary
  require 'open3'
  #How to execute a command from the command line

  #First, get the name of the file
  @fileName = 'bsh-2.0b4.jar'

  #run the program
  @commandName = 'java -cp ' + @fileName  + ' bsh.Interpreter'

  stdin, stdout, stderr, wait_thr= Open3.popen3(@commandName)
  @commandExec  = "Stack stack = new Stack();\n System.out.println(\"Stack size: \" + stack.size());\n stack.add(1);\n System.out.println(\"Stack size: \" + stack.size());\n"
  p 'Execute program'
  stdin.print( @commandExec)
  stdin.flush()

  p 'Print Standard Output'
  #@output = stdout.readline;

  begin
    stdout.each { |line| print line }
  rescue Errno::EIO
  end


  p 'Print Standard Error'
  @output = stderr.gets
  while @output != nil

    p 'Output: ' + @output
    @output = stderr.gets
  end

  #Try again


  p 'Execute program'
  #Write Execution program
  @commandExec  = "stack.add(2);\n System.out.println(\"Stack size: \" + stack.size());\n"
  stdin.print( @commandExec)
  stdin.flush()

  p 'Print Standard Output'
  @output = ''
  while @output != nil
    output = stdout.gets
    p output
  end


  p 'Print Standard Error'
  @output = ''
  while @output != nil
    output = stderr.gets
    p output
  end


end