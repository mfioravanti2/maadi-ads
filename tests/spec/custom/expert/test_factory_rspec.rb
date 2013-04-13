# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : test_factory_spec.rb
# License: Creative Commons Attribution
#
# Summary: Rspec tests for the Expert factory

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/expert/factory'

describe Maadi::Expert::Expert do
  it 'returns String Array of custom Expert names that can be loaded' do
    list = Maadi::Expert::Expert::choices
    list.length.should_not eq(0)
  end

  it 'returns an instantiated custom Expert object' do
    list = Maadi::Expert::Expert::choices
    expert = Maadi::Expert::Expert::factory(list.sample)
    expect(expert).to_not eq(nil)
  end

  it 'does NOT return a custom Application object for one that does not exist' do
    expert = Maadi::Expert::Expert::factory('NotFound')
    expert.should be_nil
  end
end
