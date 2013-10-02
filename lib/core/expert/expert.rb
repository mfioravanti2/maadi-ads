# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : expert.rb
#
# Summary: The expert represents a collection of knowledge about a specific
#          domain.  This class is an abstract class and should be created
#          to represent specific domains of knowledge.  For example, a domain
#          expert could be created for a Database, Spreadsheet, or a Word
#          processor.

require_relative '../generic/generic'
require_relative 'builder'
require_relative 'model'
require_relative '../procedure/procedure'
require_relative '../helpers'

module Maadi
  module Expert
    class Expert < Maadi::Generic::Generic
      # type (String) is a convenient human readable label.
      def initialize(type)
        super(type)

        @options['USE-BUILDER'] = 'FALSE'
        @notes['USE-BUILDER'] = 'TRUE/FALSE Use a Builder to assist in procedure construction'

        @options['BUILD-NAME'] = ''
        @notes['BUILD-NAME'] = 'XML file which contains the build script'

        @options['USE-MODEL'] = 'FALSE'
        @notes['USE-MODEL'] = 'TRUE/FALSE Use an External Model to assist in procedure construction'

        @options['MODEL-NAME'] = ''
        @notes['MODEL-NAME'] = 'Ruby class file which contains the Model for the Expert'

        @builder = nil
        @model = nil
      end

      def domain
        return ''
      end

      # prepare will setup the execution environment.  No tests will be executed but all required
      # resources and services will be prepared to execution.
      # return (bool) true if all of the components are read.
      def prepare
        if @options['USE-BUILDER'] == 'TRUE'
          if File.exists?( "../lib/custom/expert/builders/#{@options['BUILD-NAME']}.xml" )
            Maadi::post_message(:More, "Expert (#{@type}) preparing Procedure Builder")

            @builder = Builder.new()
            @builder.set_option( 'BUILD-NAME', @options['BUILD-NAME'] )

            @builder.prepare
          else
            Maadi::post_message(:Warn, "Expert (#{@type}) unable to access Procedure Build File")
            return false
          end
        end

        if @options['USE-MODEL'] == 'TRUE'
          if File.exists?( "../lib/custom/expert/models/#{@options['MODEL-NAME']}.rb" )
            require_relative "../../../lib/custom/expert/models/#{@options['MODEL-NAME']}"

            class_name = Object.const_get('Maadi').const_get('Expert').const_get('Models').const_get(@options['MODEL-NAME'])
            @model = class_name.new()

            @model.prepare
          else
            Maadi::post_message(:Warn, "Expert (#{@type}) unable to access Model File")
            return false
          end
        end

        Maadi::post_message(:More, "Expert (#{@type}) is ready")
        super
      end

      # provide a list of possible tests
      # return (Array of Strings) with each element representing the name of
      # a test that this domain expert can generate
      def tests
        return Array.new
      end

      # provide a list of possible configurable attributes for an individual test.
      # test (String) name of a test (must be on the list generated by the tests function)
      #   test can either be for a specific test or 'all', if 'all' the entire list of
      #   configurable parameters will be returned.
      # return (Array of Parameters) return an array of configurable parameters for the test
      def parameters( test )
        if test == 'all'

          return Array.new
        else

          return Array.new
        end
      end

      # create a specific test procedure that can be executed against an application.
      # test (String) name of a test (must be on the list generated by the tests function)
      # parameters (Array of Parameters) array of selected parameters for the desired test
      # return (Procedure) return complete test procedure that is ready to be executed.
      def procedure( test, procedure )
        if procedure == nil
          procedure = Maadi::Procedure::Procedure.new( test )
        end

        return procedure
      end

      # teardown the object if any database connections, files, etc. are open.
      def teardown
        Maadi::post_message(:Less, "Expert (#{@type}) is NO longer ready")

        if @builder != nil
          @builder.teardown
          @builder = nil
        end

        if @model != nil
          @model.teardown
          @model = nil
        end
        super
      end

      def self.is_expert?( expert )
        if expert != nil
          if expert.is_a?( Maadi::Expert::Expert )
            return true
          end
        end

        return false
      end
    end
  end
end