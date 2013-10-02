require 'rubygems'

require_relative '../lib/core/expert/expert'

builder = Maadi::Expert::Builder::Builder.new()
builder.set_option('BUILD-NAME', 'ADSStack')
builder.prepare

procedure = builder.procedure('CREATE',nil)

if procedure != nil
  puts "Procedure named #{procedure.id} was created."

  procedure.steps.each do |step|
    puts "\tSTEP: #{step.id}"
  end
end

procedure = builder.procedure('CREATE',procedure)

if procedure != nil
  puts "Procedure named #{procedure.id} was updated."

  procedure.steps.each do |step|
    puts "\tSTEP: #{step.id}"
  end
end

builder.teardown