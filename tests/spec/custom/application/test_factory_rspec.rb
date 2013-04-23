# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : test_factory_spec.rb
#
# Summary: Rspec tests for the Application factory

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/application/factory'

describe Maadi::Application::Application do
  it 'returns String Array of custom Application names that can be loaded' do
    list = Maadi::Application::Application::choices
    list.length.should_not eq(0)
  end

  it 'returns an instantiated custom Application object' do
    list = Maadi::Application::Application::choices
    application = Maadi::Application::Application::factory(list.sample)
    expect(application).to_not eq(nil)
  end

  it 'does NOT return a custom Application object for one that does not exist' do
    application = Maadi::Application::Application::factory('NotFound')
    application.should be_nil
  end
end
