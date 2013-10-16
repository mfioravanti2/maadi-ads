

require 'nokogiri'
require 'green_shoes'
module Maadi
  module Application
    module UI
      class Xmlattributewrapper  < Shoes::Widget

        attr_accessor :xmlAttribute, :text, :editLine
        def initialize opts={}

          @xmlAttribute = opts[:xmlAttribute]
          @text = inscription @xmlAttribute.name.to_s, width: 50
          @editLine = edit_line @xmlAttribute.value.to_s , width:50
          p 'Attr: ' + @xmlAttribute.name.to_s + ' value:' + @xmlAttribute.value
          @editLine.change do
            @xmlAttribute.parent[@xmlAttribute.name.to_s] =  @editLine.text
          end
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

        def showSelf
          @text.show
          @editLine.show
        end

        def hideSelf
          @text.hide
          @editLine.hide
        end

        def teardown
          @text.remove
          @editLine.remove

        end

      end
    end
  end
end
