
#Uses the XMLParser and XMLUI (shoes) to create an interactive UI for handling XML data.


require_relative 'XMLParser'
require_relative 'XMLUI'

module Maadi
  module UI
    class XMLStarter

      def initialize(fileName)

        #Set it to local directory if it is not passed anything
        if fileName == nil
          @fileName = 'test.xml'
        end

        #start up the process
        createXMLParser()
        createXMLUI()
      end

      def createXMLParser
        @xMLParser = Maadi::UI::XMLParser.new(@fileName)
      end

      def createXMLUI
        @createXMLUI = Maadi::UI::XMLStarter.new(@xMLParser)
      end
    end
  end
end