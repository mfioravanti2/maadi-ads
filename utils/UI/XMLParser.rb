

#Loads a XML file and sets a variable with the specific XML node object.

require_relative '../../lib/core/generic/generic'

require 'rubygems'
require 'nokogiri'

module Maadi
  module Application
    module UI
      class XMLParser  < Maadi::Generic::Generic

        def initialize(fileName)
          if File.exists?( "test.xml" )
            #Maadi::post_message(:More, "XMLParser loading files")

            fXML = File.open( "test.xml" )
            @xMLObject = Nokogiri::XML(fXML)
            fXML.close


          else
            #Maadi::post_message(:Warn, "XMLParser (#{@type}) unable to access files")
            return false
          end

        end


        def getXMLObject
          return @xMLObject
        end
      end
    end
  end
end