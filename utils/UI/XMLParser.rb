

require 'rubygems'
require 'nokogiri'

#Loads a XML file and sets a variable with the specific XML node object.
module Maadi
  module UI
    class XMLParser

      def initialize(fileName)
        @xMLObject = ''

      end


      def getXMLObject
        return @xMLObject
      end
    end
  end
end