# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : test_ConstraintPickList_rspec.rb
#
# Summary: This is the rspec unit test for the ConstraintPickList class

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/procedure/ConstraintSingleWord'
require_relative '../../../../lib/custom/procedure/ConstraintPickList'

describe Maadi::Procedure::ConstraintPickList do
  it 'selects a single string within the list' do
    length = 1 + rand(25).to_i
    list = Array.new
    length.times do |number|
      constraint = Maadi::Procedure::ConstraintSingleWord.new(1,length)
      list.push constraint.satisfy
    end

    puts "Length: #{length}"
    constraint = Maadi::Procedure::ConstraintPickList.new( list )
    resultant = constraint.satisfy

    expect(list).to include(resultant)
  end

  it 'is able to produce a value which satisfies its own constraint' do
    length = 1 + rand(25).to_i
    list = Array.new
    length.times do |number|
      constraint = Maadi::Procedure::ConstraintSingleWord.new(1,length)
      list.push constraint.satisfy
    end

    puts "Length: #{length}"
    constraint = Maadi::Procedure::ConstraintPickList.new( list )
    resultant = constraint.satisfy

    expect( constraint.satisfies?( resultant ) ).to eq(true)
  end
end
