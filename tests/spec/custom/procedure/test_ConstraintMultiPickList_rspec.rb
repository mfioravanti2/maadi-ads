# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : test_ConstraintMultiPickList_rspec.rb
#
# Summary: This is the rspec unit test for the ConstraintMultiPickList class

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/procedure/ConstraintSingleWord'
require_relative '../../../../lib/custom/procedure/ConstraintMultiPickList'

describe Maadi::Procedure::ConstraintMultiPickList do
  it 'generates a single string of characters up to a maximum specified length' do
    length = 1 + rand(25).to_i
    list = Array.new
    length.times do |number|
      constraint = Maadi::Procedure::ConstraintSingleWord.new(1,length)
      list.push constraint.satisfy
    end

    selected = 1 + rand(25).to_i
    constraint = Maadi::Procedure::ConstraintMultiPickList.new( selected, list )
    resultant = constraint.satisfy

    puts "Length: #{length}, Requested: #{selected}, Returned: #{constraint.count}"
    expect(resultant.length).to be == (constraint.count)
  end
end
