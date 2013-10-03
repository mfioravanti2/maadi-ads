# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 10/01/2013
# File   : builder.rb
#
# Summary: The build will take an XML configuration file and use the options
#          to build the procedures for an expert.

require 'rubygems'
require 'nokogiri'

require_relative '../generic/generic'
require_relative '../procedure/procedure'
require_relative '../helpers'

module Maadi
  module Expert
    module Models
      class Model < Maadi::Generic::Generic
        # type (String) is a convenient human readable label.
        def initialize(type)
          super(type)

          @values = Hash.new
        end

        # prepare will setup the execution environment.  No tests will be executed but all required
        # resources and services will be prepared to execution.
        # return (bool) true if all of the components are read.
        def prepare
          Maadi::post_message(:More, "Model (#{@type}) is ready")

          super
        end

        def values
          return @values.keys
        end

        def has_value?( attribute )
          return @values.keys.include?( attribute )
        end

        def set_value( attribute, value )
          if @values.keys.include?( attribute )
            @values[attribute] = value
          end
        end

        def get_value( attribute )
          if @values.keys.include?( attribute )
            return @values[attribute]
          end

          return ''
        end

        # teardown the object if any database connections, files, etc. are open.
        def teardown
          Maadi::post_message(:Less, "Model (#{@type}) is NO longer ready")
          super
        end

        def self.is_model?( model )
          if model != nil
            if model.is_a?( Maadi::Expert::Models::Model )
              return true
            end
          end

          return false
        end
      end
    end
  end
end