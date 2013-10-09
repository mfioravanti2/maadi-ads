require 'rubygems'

require_relative '../lib/core/expert/expert'
require_relative '../lib/custom/expert/ADSStack'
require_relative '../lib/custom/expert/models/ADSStack'

expert = Maadi::Expert::ADSStack.new('ADSStack')
model = Maadi::Expert::Models::ADSStack.new()

builder = Maadi::Expert::Builder::Builder.new()
builder.set_option('USE-BUILDER', 'TRUE')
builder.set_option('BUILD-NAME', 'ADSStack')
builder.set_option('USE-MODEL', 'FALSE')
builder.prepare

test = 'DETAILS'

procedure = builder.procedure( 'CREATE', nil, expert, model )
procedure = builder.procedure( 'CREATE', procedure, expert, model )


procedure = builder.procedure( test, nil, expert, model )

if procedure != nil
  puts "Procedure named #{procedure.id} was created (Status: #{ ( procedure.is_complete? ) ? 'DONE' : 'WIP'}, #{ ( procedure.has_failed? ) ? 'SUCCESS' : 'FAILED'})."

  procedure.steps.each do |step|
    puts "\tSTEP: #{step.id} (Looking for #{step.look_for})"
    step.parameters.each do |parameter|
      puts "\t\tPARAMETER: #{parameter.label} = #{parameter.value}"
      if parameter.constraint != nil
        puts "\t\t\tCONSTRAINT: #{parameter.constraint.display}"
      end
    end
  end
end

if test == 'PUSH'
  procedure.get_step( 'PUSH-WIP' ).get_parameter( '[RVALUE]' ).populate_value
end

procedure = builder.procedure( test, procedure, expert, model )

if procedure != nil
  puts "Procedure named #{procedure.id} was updated (Status: #{ ( procedure.is_complete? ) ? 'DONE' : 'WIP'}, #{ ( procedure.has_failed? ) ? 'SUCCESS' : 'FAILED'})."

  procedure.steps.each do |step|
    puts "\tSTEP: #{step.id} (Looking for #{step.look_for})"
    step.parameters.each do |parameter|
      puts "\t\tPARAMETER: #{parameter.label} = #{parameter.value}"
      if parameter.constraint != nil
        puts "\t\t\tCONSTRAINT: #{parameter.constraint.display}"
      end
    end
  end
end


expert.teardown
builder.teardown