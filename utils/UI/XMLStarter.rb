
#Uses the XMLParser and XMLUI (shoes) to create an interactive UI for handling XML data.


require_relative('XMLParser')
require_relative('XMLUI')
require_relative '../../lib/core/generic/generic'

require 'rubygems'
require 'nokogiri'
require 'green_shoes'

module Maadi
  module Application
    module UI
      class XMLStarter  < Maadi::Generic::Generic

        def initialize(fileName)
          p 'Starting application'

          #Set it to local directory if it is not passed anything
          if fileName == nil
            @fileName = 'test.xml'
          end

          #start up the process
          createXMLParser()
          createXMLUI()



        end

        def createXMLParser
          p 'Createing parser'
          @xMLParser = Maadi::Application::UI::XMLParser.new(@fileName)

        end

        def createXMLUI
          p 'Createing UI'
          @createXMLUI = Maadi::Application::UI::XMLUI.new(@xMLParser.getXMLObject())

        end
      end
    end
  end
end

p 'STARTER ACTIVATED'
starter = Maadi::Application::UI::XMLStarter.new(nil)
p 'Finished'