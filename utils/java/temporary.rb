class Temporary
  require 'open3'
  #How to execute a command from the command line

  #First, get the name of the file
  @fileName = 'bsh-2.0b4.jar'
  @filePath = Dir.pwd
  @file = @filePath + '/' +  @fileName
  p @file
  #run the program
  #@commandName = 'java -jar ' + @fileName
  #The method below assumes that the bsh file is in jre/lib/ext for ease of access
  #@commandName = 'java bsh.Interpreter'
  @commandName = 'java -cp ' + @file  + ' bsh.Interpreter'
  #io = IO.popen(@commandName, 'r+')
  #$stdout = io
  #io.write 'Stack stack = new Stack();\n'
  #io.write 'System.out.println(stack.size());\n'
  #$stdout = IO.new 0
  #p io.read(1)
  #io.close

  stdin, stdout, stderr = Open3.popen3(@commandName)
  @commandExec  = 'Stack stack = new Stack(); System.out.println(stack.size());'
  #stdin.print(@commandExec )
  stdin.print @commandExec
  stdin.close()
  p stdout.readlines()
  p stderr.read()



end