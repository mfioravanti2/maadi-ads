require 'rubygems'

require_relative '../lib/core/expert/expert'
require_relative '../lib/custom/expert/ADSStack'

expert = Maadi::Expert::ADSStack.new('ADSStack')

builder = Maadi::Expert::Builder::Builder.new()
builder.set_option('USE-BUILDER', 'TRUE')
builder.set_option('BUILD-NAME', 'ADSStack')
builder.set_option('USE-MODEL', 'FALSE')
builder.prepare

test = 'POP'

procedure = builder.procedure( test, nil, expert, nil )

if procedure != nil
  puts "Procedure named #{procedure.id} was created."

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

procedure = builder.procedure( test, procedure, expert, nil )

if procedure != nil
  puts "Procedure named #{procedure.id} was updated."

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