# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : test_factory_spec.rb
#
# Summary: Rspec tests for the Organizer factory

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/organizer/factory'

describe Maadi::Organizer::Organizer do
  it 'returns String Array of custom Organizer names that can be loaded' do
    list = Maadi::Organizer::Organizer::choices
    list.length.should_not eq(0)
  end

  it 'returns an instantiated custom Organizer object' do
    list = Maadi::Organizer::Organizer::choices
    monitor = Maadi::Organizer::Organizer::factory(list.sample)
    expect(monitor).to_not eq(nil)
  end

  it 'does NOT return a custom Organizer object for one that does not exist' do
    monitor = Maadi::Organizer::Organizer::factory('NotFound')
    monitor.should be_nil
  end
end
