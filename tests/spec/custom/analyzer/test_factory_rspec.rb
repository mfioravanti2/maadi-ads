# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : test_factory_spec.rb
# License: Creative Commons Attribution
#
# Summary: Rspec tests for the Analyzer factory

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/analyzer/factory'

describe Maadi::Analyzer::Analyzer do
  it 'returns String Array of custom Analyzer names that can be loaded' do
    list = Maadi::Analyzer::Analyzer::choices
    list.length.should_not eq(0)
  end

  it 'returns an instantiated custom Analyzer object' do
    list = Maadi::Analyzer::Analyzer::choices
    analyzer = Maadi::Analyzer::Analyzer::factory(list.sample, false)
    expect(analyzer).to_not eq(nil)
  end

  it 'does NOT return a custom Analyzer object for one that does not exist' do
    analyzer = Maadi::Analyzer::Analyzer::factory('NotFound', false)
    analyzer.should be_nil
  end
end
