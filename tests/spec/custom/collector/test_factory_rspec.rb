# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : test_factory_spec.rb
# License: Creative Commons Attribution
#
# Summary: Rspec tests for the Collector factory

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/collector/factory'

describe Maadi::Collector::Collector do
  it 'returns String Array of custom Collector names that can be loaded' do
    list = Maadi::Collector::Collector::choices
    list.length.should_not eq(0)
  end

  it 'returns an instantiated custom Collector object' do
    list = Maadi::Collector::Collector::choices
    collector = Maadi::Collector::Collector::factory(list.sample)
    expect(collector).to_not eq(nil)
  end

  it 'does NOT return a custom Collector object for one that does not exist' do
    collector = Maadi::Collector::Collector::factory('NotFound')
    collector.should be_nil
  end
end
