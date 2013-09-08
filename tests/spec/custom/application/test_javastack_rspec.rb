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
    javaStack = Maadi::Application::JavaStack.new()
    javaStack.prepare()
    #javaStack.execute(1, NULCONSTRUCT)
    #Some EQ statement
  end
end