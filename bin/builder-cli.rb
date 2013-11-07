require 'rubygems'
require 'json'
require 'open3'

require_relative '../lib/custom/factories'

dbsql = Maadi::Collector::Collector.factory('SQLite3')
dbfile = Maadi::Collector::Collector.factory('LogFile')

dbsql.prepare
dbfile.prepare

expert = Maadi::Expert::Expert.factory('ADSAxiomaticStack')
#expert = Maadi::Expert::Expert.factory('ADSAxiomaticQueue')
expert.prepare

#tests = %w(CREATE PUSH PEEK TOP BOTTOM)
tests = %w(CREATE PUSH PUSHPOP PUSH PUSHPOP PUSH PUSHPOP)

tests.each do |test|
  puts "\n\n**** NEXT PROCEDURE ****\n"
  #puts "MODEL: STACK-EXISTS=#{model.get_value('STACK-EXISTS')}, STACK-SIZE=#{model.get_value('STACK-SIZE')}"

  procedure = expert.procedure( test, nil )

  if procedure != nil
  if %w(ENQUEUE ENQUEUEDEQUEUE ENQUEUEDEQUEUESIZE PUSH PUSHPOP PUSHPOPSIZE ATINDEX NEWSTACKINDEX NEWSTACKSIZE).include?(test)
    procedure.steps.each do |step|
      step.parameters.each do |parameter|
        if parameter.constraint != nil
          parameter.populate_value
        end
      end
    end
  end

  procedure.show
  procedure = expert.procedure( test, procedure )
  procedure.show

  dbsql.log_procedure( procedure )
  dbfile.log_procedure( procedure )
  end
end

expert.teardown

dbsql.teardown
dbfile.teardown

puts "Process ID #{Process.pid}"

mem_cmd = 'D:/Code/C++/Monitor-SysMemory/Debug/Monitor-SysMemory.exe'
json_text = ''
Open3.popen3(mem_cmd) do |stdin, stdout, stderr, wait_thr|
  json_text = stdout.read
end
#puts json_text
json_obj = JSON.parse( json_text )
puts "Total Physical Memory #{json_obj['physical']['total']['size']} #{json_obj['physical']['total']['units']}"

mem_cmd = "D:/Code/C++/Monitor-Process/Debug/Monitor-Process.exe -pid=#{Process.pid}"
json_text = ''
Open3.popen3(mem_cmd) do |stdin, stdout, stderr, wait_thr|
  json_text = stdout.read
end
json_text.gsub!( /\\/, '/' )
#puts json_obj
json_obj = JSON.parse( json_text )
puts "Process Name=#{json_obj['name']} PID=#{json_obj['pid']}"

