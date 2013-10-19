# Author : Scott Forest Hull II (shull2013@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 10/19/2013
# File   : Xmlattributewrapper.rb
#
# Summary: A wrapper for holding data and ui widgets
#          regarding representations for xml attributes.

require 'nokogiri'
require 'green_shoes'
module Maadi
    module UI
      class Xmlattributewrapper  < Shoes::Widget

        #Attributes
        attr_accessor :xmlAttribute, :text, :editLine

        #Constructor
        #Takes an Nokogiri XML attribute
        def initialize opts={}

          if opts[:xmlAttribute].is_a? ( Nokogiri::XML::Attr)
            @xmlAttribute = opts[:xmlAttribute]
            @text = inscription @xmlAttribute.name.to_s, width: 50
            @editLine = edit_line @xmlAttribute.value.to_s , width:50
            p 'Attr: ' + @xmlAttribute.name.to_s + ' value:' + @xmlAttribute.value
            @editLine.change do
              @xmlAttribute.parent[@xmlAttribute.name.to_s] =  @editLine.text
            end
          end
        end

        #Returns the Shoes UI Text box
        def getText
          return @text
        end

        #Returns the Shoes UI edit_line
        def getEditLine
          return @editLine
        end

        #Returns the Nokogiri XML Attr
        def getXmlAttribute
          return @xmlAttribute
        end

        #Shoes self
        def showSelf
          @text.show
          @editLine.show
        end

        #Hides self
        def hideSelf
          @text.hide
          @editLine.hide
        end

        #A deconstructor
        def teardown
          @text.remove
          @editLine.remove

        end

      end
    end
end
