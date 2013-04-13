# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : test_ConstantSingleWord_rspec.rb
# License: Creative Commons Attribution
#
# Summary: This is the rspec unit test for the ConstraintSingleWord class

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/procedure/ConstraintSingleWord'

describe Maadi::Procedure::ConstraintSingleWord do
  it 'generates a single string of characters up to a maximum specified length' do
    length_a = rand(25)
    length_b = length_a + rand(25)

    constraint = Maadi::Procedure::ConstraintSingleWord.new(length_a, length_b)
    resultant = constraint.satisfy

    puts "#{length_a} <= #{resultant.length} <= #{length_b}"
    expect(resultant.length).to be <= (length_b)
  end

  it 'generates a single string of characters greater than a minimum specified length' do
    length_a = rand(25)
    length_b = length_a + rand(25)

    constraint = Maadi::Procedure::ConstraintSingleWord.new(length_a, length_b)
    resultant = constraint.satisfy

    puts "#{length_a} <= #{resultant.length} <= #{length_b}"
    expect(resultant.length).to be >= (length_a)
  end

  it 'is able to produce a value which satisfies its own constraint' do
    length_a = rand(25)
    length_b = length_a + rand(25)

    constraint = Maadi::Procedure::ConstraintSingleWord.new(length_a, length_b)
    resultant = constraint.satisfy

    expect( constraint.satisfies?( resultant ) ).to eq(true)
  end
end
