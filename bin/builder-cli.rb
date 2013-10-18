require 'rubygems'

require_relative '../lib/custom/factories'

expert = Maadi::Expert::Expert.factory('ADSAxiomaticStack')
expert.set_option('BUILD-NAME', 'ADSAxiomaticStack')
expert.set_option('USE-BUILDER', 'TRUE')
expert.set_option('MODEL-NAME', 'ADSStack')
expert.set_option('USE-MODEL', 'TRUE')
expert.prepare

tests = %w(CREATE SIZE NEWSTACKSIZE)

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
  procedure = expert.procedure( test, procedure )
  procedure.show
end

expert.teardown
