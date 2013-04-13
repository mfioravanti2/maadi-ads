# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : test_ConstraintConstant_rspec.rb
# License: Creative Commons Attribution
#
# Summary: This is the rspec unit test for the ConstraintConstant class

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/procedure/ConstraintConstant'

describe Maadi::Procedure::ConstraintConstant do
  it 'always returns the same string which was passed into it' do
    value = rand(25)

    constraint = Maadi::Procedure::ConstraintConstant.new(value)
    resultant = constraint.satisfy

    puts "#{value.to_s} ?= #{resultant.to_s}"
    expect(resultant.to_s).to be == (value.to_s)
  end

  it 'is able to produce a value which satisfies its own constraint' do
    value = rand(25)

    constraint = Maadi::Procedure::ConstraintConstant.new(value)
    resultant = constraint.satisfy

    expect( constraint.satisfies?( resultant ) ).to eq(true)
  end
end
