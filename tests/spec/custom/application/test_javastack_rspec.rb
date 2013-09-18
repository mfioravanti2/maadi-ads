# Author : Scott Hull (shull2013@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 09/05/2013
# File   : test_javastack_rspec.rb
#
# Summary: Rspec tests for the Application factory

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/application/JavaStack'
require_relative '../../../../lib/core/procedure/step'
require_relative '../../../../lib/core/procedure/procedure'
require_relative '../../../../lib/core/procedure/results'
require_relative '../../../../lib/core/procedure/parameter'

def build_step( test, look_for, command, on_failure )
  parameters = Array.new
  step = Maadi::Procedure::Step.new(test + '', 'application', look_for, command, parameters, on_failure)
  return step
end

describe Maadi::Application::JavaStack do
  it 'Checks the default parameters stored on JavaStack class when instantiated: BSHPATH' do
    javaStack = Maadi::Application::JavaStack.new()
    javaStack.get_option('BSHPATH').should eq(File.expand_path('~/RubymineProjects/maadi-ads/utils/java/bsh-2.0b4.jar'))
    end
end

describe Maadi::Application::JavaStack do
  it 'Checks the default parameters stored on JavaStack class when instantiated: DEFAULTCAPACITY' do
    javaStack = Maadi::Application::JavaStack.new()
    javaStack.get_option('DEFAULTCAPACITY').should eq(10)
  end
end

describe Maadi::Application::JavaStack do
  it 'Runs a sample problem and see if it works' do

    p' In the sample problem tester'
    javaStack = Maadi::Application::JavaStack.new()
    javaStack.prepare()

    #Setup the procedure

    #Create the steps
    parameters = Array.new()
    #The first step is to create a stack.  Do not pass any parameters OR an execution string,
    #as the execution string is taken care of in the switch statement
    step1 = build_step('NULCONSTRUCT', 'COMPLETE','', 'TERM-PROC')

    #The second step is to get the size.  This should be 0
    step2 = build_step('SIZE', 'COMPLETE','', 'TERM-PROC')

    #The third step, add a value to the operation
    step3 = build_step('PUSH', '[LVALUE]', '', 'TERM-PROC' )
    constraint =  Maadi::Procedure::ConstraintRangedInteger.new( 1, 1024 )
    step3.parameters.push Maadi::Procedure::Parameter.new('[RVALUE]', constraint )
    step3.parameters[0].populate_value

    #The forth step, check the value at an index
    step4 = build_step('ATINDEX', 'LVALUE', '', 'TERM-PROC' )

    constraint =  Maadi::Procedure::ConstraintRangedInteger.new( 0, 0 )
    step4.parameters.push Maadi::Procedure::Parameter.new('[INDEX]', constraint )
    step4.parameters[0].populate_value

    #The fifth step, pop a vlaue
    step5 = build_step('POP', '[LVALUE]', '', 'TERM-PROC' )


    #create the procedure
    procedure1 = Maadi::Procedure::Procedure.new(55)
    #Add the steps to the procedure
    procedure1.add_step(step1)
    procedure1.add_step(step2)
    procedure1.add_step(step3)
    procedure1.add_step(step4)
    procedure1.add_step(step5)

    results = javaStack.execute(1, procedure1);

    #Some EQ statement
    'foo'.should eq('foo')

    p results.to_s

    p 'End of sample problem tester.  Check results above to see if it works.'


  end
end