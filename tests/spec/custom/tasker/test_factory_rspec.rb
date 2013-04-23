# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : test_factory_spec.rb
#
# Summary: Rspec tests for the Tasker factory

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/tasker/factory'

describe Maadi::Tasker::Tasker do
  it 'returns String Array of custom Tasker names that can be loaded' do
    list = Maadi::Tasker::Tasker::choices
    list.length.should_not eq(0)
  end

  it 'returns an instantiated custom Tasker object' do
    list = Maadi::Tasker::Tasker::choices
    tasker = Maadi::Tasker::Tasker::factory(list.sample)
    expect(tasker).to_not eq(nil)
  end

  it 'does NOT return a custom Tasker object for one that does not exist' do
    tasker = Maadi::Tasker::Tasker::factory('NotFound')
    tasker.should be_nil
  end
end
