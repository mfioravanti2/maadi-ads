

require 'nokogiri'
require 'green_shoes'
module Maadi
  module Application
    module UI
      class XMLElementWrapper

        attr_accessor :xmlAttribute, :text, :editLine
        def initialize(xmlAttribute, text, editLine)
          @xmlAttribute = xmlAttribute
          @text = text
          @editLine = editLine

        end

        def getText
          return @text
        end

        def getEditLine
          return @editLine
        end

        def getXmlAttribute
          return @xmlAttribute
        end

      end
    end
  end
end
