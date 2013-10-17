# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 10/16/2013
# File   : ADSQueue.rb
#
# Summary: This is a Model for a Queue

require_relative '../factory'
require_relative '../../../core/helpers'

module Maadi
  module Expert
    module Models
      class ADSQueue < Model

        def initialize
          super('ADSQueue')
        end
      end
    end
  end
end