# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 09/11/2013
# File   : test_rubystack_rspec.rb
#
# Summary: Rspec tests for the Application factory

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/application/RubyStack'
require_relative '../../../../lib/core/procedure/procedure'
require_relative '../../../../lib/core/procedure/results'

def build_step( test, look_for, command, on_failure )
  parameters = Array.new
  step = Maadi::Procedure::Step.new(test + '', 'application', look_for, command, parameters, on_failure)
  return step
end

describe Maadi::Application::RubyStack do
  it 'Runs a sample problem and see if it works' do

    rStack = Maadi::Application::RubyStack.new()
    rStack.prepare()

    #The first step is to create a stack.  Do not pass any parameters OR an execution string,
    #as the execution string is taken care of in the switch statement
    puts 'Creating Step 1 (NULCONSTRUCT)'
    step1 = build_step('NULCONSTRUCT', 'COMPLETED','', 'TERM-PROC')

    #The second step is to get the size.  This should be 0
    puts 'Creating Step 1 (SIZE)'
    step2 = build_step('SIZE', 'COMPLETED','', 'TERM-PROC')

    #The third step, add a value to the operation
    step3 = build_step('PUSH', 'LVALUE', '', 'TERM-PROC' )
    constraint =  Maadi::Procedure::ConstraintRangedInteger.new( 1, 1024 )
    step3.parameters.push Maadi::Procedure::Parameter.new('[RVALUE]', constraint )
    step3.parameters[0].populate_value
    rValue = step3.parameters[0].value
    puts "Creating Step 1 (PUSH w/#{rValue})"

    #The forth step, pop a vlaue
    puts 'Creating Step 4 (POP)'
    step4 = build_step('POP', 'LVALUE', '', 'TERM-PROC' )

    #create the procedure
    procedure1 = Maadi::Procedure::Procedure.new(55)
    #Add the steps to the procedure
    procedure1.add_step(step1)
    procedure1.add_step(step2)
    procedure1.add_step(step3)
    procedure1.add_step(step4)

    puts 'Executing Procedure'
    results = rStack.execute(1, procedure1)

    results.results.each do |result|
      puts "Results for Step #{result.step_name} is #{result.status} with #{result.data}"
    end

    rValue.to_s.should eq(results.results[3].data.to_s)
  end
end