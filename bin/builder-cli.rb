require 'rubygems'

require_relative '../lib/core/expert/expert'

builder = Maadi::Expert::Builder::Builder.new()
builder.set_option('USE-BUILDER', 'TRUE')
builder.set_option('BUILD-NAME', 'ADSStack')
builder.set_option('USE-MODEL', 'FALSE')
builder.prepare

procedure = builder.procedure( 'PUSH', nil, nil, nil )

if procedure != nil
  puts "Procedure named #{procedure.id} was created."

  procedure.steps.each do |step|
    puts "\tSTEP: #{step.id}"
    step.parameters.each do |parameter|
      puts "\t\tPARAMETER: #{parameter.label}"
      if parameter.constraint != nil
        puts "\t\t\tCONSTRAINT: #{parameter.constraint.type}"
      end
    end
  end
end

procedure = builder.procedure( 'CREATE',procedure, nil, nil )

if procedure != nil
  puts "Procedure named #{procedure.id} was updated."

  procedure.steps.each do |step|
    puts "\tSTEP: #{step.id}"
    step.parameters.each do |parameter|
      puts "\t\tPARAMETER: #{parameter.label}"
      if parameter.constraint != nil
        puts "\t\t\tCONSTRAINT: #{parameter.constraint.type}"
      end
    end
  end
end

builder.teardown