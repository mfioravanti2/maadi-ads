require 'rubygems'

require_relative '../lib/custom/factories'

dbsql = Maadi::Collector::Collector.factory('SQLite3')
dbfile = Maadi::Collector::Collector.factory('LogFile')

dbsql.prepare
dbfile.prepare

expert = Maadi::Expert::Expert.factory('ADSAxiomaticStack')
expert.set_option('BUILD-NAME', 'ADSAxiomaticStack')
expert.set_option('USE-BUILDER', 'TRUE')
expert.set_option('MODEL-NAME', 'ADSStack')
expert.set_option('USE-MODEL', 'TRUE')
expert.prepare

tests = %w(CREATE SIZE NEWSTACKSIZE PUSH PUSHPOPSIZE PUSHPOPSIZE)

tests.each do |test|
  puts "\n\n**** NEXT PROCEDURE ****\n"
  #puts "MODEL: STACK-EXISTS=#{model.get_value('STACK-EXISTS')}, STACK-SIZE=#{model.get_value('STACK-SIZE')}"

  procedure = expert.procedure( test, nil )

  if %w(PUSH PUSHPOP PUSHPOPSIZE ATINDEX NEWSTACKINDEX NEWSTACKSIZE).include?(test)
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

expert.teardown

dbsql.teardown
dbfile.teardown
