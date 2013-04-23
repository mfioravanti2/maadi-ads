# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : test_ConstraintRangedInteger_rspec.rb
#
# Summary: This is the rspec unit test for the ConstraintRangedInteger class

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/procedure/ConstraintRangedInteger'

describe Maadi::Procedure::ConstraintRangedInteger do
  it 'generates a random number less than or equal to a maximum specified value' do
    length_a = rand(25).to_i
    length_b = length_a + rand(25).to_i

    constraint = Maadi::Procedure::ConstraintRangedInteger.new(length_a, length_b)
    resultant = constraint.satisfy

    puts "#{length_a} <= #{resultant} <= #{length_b}"
    expect(resultant).to be <= (length_b)
  end

  it 'generates a random number greater than or equal to a minimum specified value' do
    length_a = rand(25).to_i
    length_b = length_a + rand(25).to_i

    constraint = Maadi::Procedure::ConstraintRangedInteger.new(length_a, length_b)
    resultant = constraint.satisfy

    puts "#{length_a} <= #{resultant} <= #{length_b}"
    expect(resultant).to be >= (length_a)
  end
end
