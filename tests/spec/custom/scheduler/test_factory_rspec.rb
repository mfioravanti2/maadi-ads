# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : test_factory_spec.rb
# License: Creative Commons Attribution
#
# Summary: Rspec tests for the Scheduler factory

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/scheduler/factory'

describe Maadi::Scheduler::Scheduler do
  it 'returns String Array of custom Scheduler names that can be loaded' do
    list = Maadi::Scheduler::Scheduler::choices
    list.length.should_not eq(0)
  end

  it 'returns an instantiated custom Scheduler object' do
    list = Maadi::Scheduler::Scheduler::choices
    scheduler = Maadi::Scheduler::Scheduler::factory(list.sample)
    expect(scheduler).to_not eq(nil)
  end

  it 'does NOT return a custom Scheduler object for one that does not exist' do
    scheduler = Maadi::Scheduler::Scheduler::factory('NotFound')
    scheduler.should be_nil
  end
end
