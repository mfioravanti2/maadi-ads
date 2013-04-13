# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : test_ConstraintMultiWord_rspec.rb
# License: Creative Commons Attribution
#
# Summary: This is the rspec unit test for the ConstraintMultiWord class

require 'rubygems'
require 'rspec'

require_relative '../../../../lib/custom/procedure/ConstraintMultiWord'

describe Maadi::Procedure::ConstraintMultiWord do
  it 'generates a single string of words up to a maximum specified length' do
    min_length = rand(25)
    max_length = min_length + rand(25)
    min_words = rand(25)
    max_words = min_words + rand(25)

    constraint = Maadi::Procedure::ConstraintMultiWord.new(min_length, max_length, min_words, max_words, ' ')
    resultant = constraint.satisfy
    words = resultant.split(' ')

    puts "Words Len : #{min_length} <= x <= #{max_length}"
    puts "# of Words: #{min_words} <= #{words.length} <= #{max_words}"
    puts "Resultant : #{resultant}"
    expect(words.length).to be <= (max_words)
  end

  it 'generates a single string of words greater than a minimum specified length' do
    min_length = rand(25)
    max_length = min_length + rand(25)
    min_words = rand(25)
    max_words = min_words + rand(25)

    constraint = Maadi::Procedure::ConstraintMultiWord.new(min_length, max_length, min_words, max_words, ' ')
    resultant = constraint.satisfy
    words = resultant.split(' ')

    puts "Words Len : #{min_length} <= x <= #{max_length}"
    puts "# of Words: #{min_words} <= #{words.length} <= #{max_words}"
    puts "Resultant : #{resultant}"
    expect(words.length).to be >= (min_words)
  end

  it 'generates a single string of words all of which are less than maximum specified length' do
    min_length = rand(25)
    max_length = min_length + rand(25)
    min_words = rand(25)
    max_words = min_words + rand(25)

    constraint = Maadi::Procedure::ConstraintMultiWord.new(min_length, max_length, min_words, max_words, ' ')
    resultant = constraint.satisfy
    words = resultant.split(' ')

    longer = false
    words.each do |word|
      longer = true if word.length > max_length
    end

    puts "Words Len : #{min_length} <= x <= #{max_length}"
    puts "# of Words: #{min_words} <= #{words.length} <= #{max_words}"
    puts "Resultant : #{resultant}"
    expect(longer).to be == false
  end

  it 'generates a single string of words greater than a minimum specified length' do
    min_length = rand(25)
    max_length = min_length + rand(25)
    min_words = rand(25)
    max_words = min_words + rand(25)

    constraint = Maadi::Procedure::ConstraintMultiWord.new(min_length, max_length, min_words, max_words, ' ')
    resultant = constraint.satisfy
    words = resultant.split(' ')

    shorter = false
    words.each do |word|
      shorter = true if word.length < min_length
    end

    puts "Words Len : #{min_length} <= x <= #{max_length}"
    puts "# of Words: #{min_words} <= #{words.length} <= #{max_words}"
    puts "Resultant : #{resultant}"
    expect(shorter).to be == false
  end

end
