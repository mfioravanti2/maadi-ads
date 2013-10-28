require 'rubygems'

require_relative '../lib/custom/factories'

dbsql = Maadi::Collector::Collector.factory('SQLite3')
dbfile = Maadi::Collector::Collector.factory('LogFile')

dbsql.prepare
dbfile.prepare

#expert = Maadi::Expert::Expert.factory('ADSAxiomaticStack')
expert = Maadi::Expert::Expert.factory('ADSAxiomaticQueue')
expert.prepare

#tests = %w(CREATE PUSH PEEK TOP BOTTOM)
tests = %w(CREATE ENQUEUE PEEK FRONT BACK)

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
  dbsql.log_procedure( procedure )
  dbfile.log_procedure( procedure )
  procedure = expert.procedure( test, procedure )
  procedure.show
  dbfile.log_procedure( procedure )
  end
end

expert.teardown

dbsql.teardown
dbfile.teardown
