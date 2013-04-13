# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : test_factory_spec.rb
# License: Creative Commons Attribution
#
# Summary: Rspec tests for the Monitor factory

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/monitor/factory'

describe Maadi::Monitor::Monitor do
  it 'returns String Array of custom Monitor names that can be loaded' do
    list = Maadi::Monitor::Monitor::choices
    list.length.should_not eq(0)
  end

  it 'returns an instantiated custom Monitor object' do
    list = Maadi::Monitor::Monitor::choices
    monitor = Maadi::Monitor::Monitor::factory(list.sample)
    expect(monitor).to_not eq(nil)
  end

  it 'does NOT return a custom Monitor object for one that does not exist' do
    monitor = Maadi::Monitor::Monitor::factory('NotFound')
    monitor.should be_nil
  end
end
