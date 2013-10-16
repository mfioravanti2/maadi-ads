require 'rubygems'
require 'nokogiri'
require 'green_shoes'

module Maadi
  module Application
    module UI
      class Xmlelementwrapper < Shoes::Widget

       attr_accessor :xmlElement, :text, :button, :xmlAttributeWraps, :xmlElementWraps
       def initialize opts={}
         @xmlElement = opts[:xmlElement]
         @text = opts[:text]
         @button = opts[:button]
         @xmlElementWraps = Array.new()

         @xmlAttributeWraps = Array.new()


         #Make all the children
         xmlElement.attribute_nodes.each do |attribute|
           keyValuePair(attribute)
         end


         #Handle button action



       end

       def getXMLElement
         return @xmlElement
       end

       def getText
         return @text
       end

       def getButton
         return button
       end

       def getXMLElements
         return @xmlElementWraps
       end

       def addXMLElement(xmlElementWrap)
         @xmlElementWraps.push(xmlElementWrap)
       end

       def addAttribute(xmlAttributeWrap)
         @xmlAttributeWraps.push(xmlAttributeWrap)
       end

       def keyValuePair(node)

         inscription node.name.to_s, width: 50
         edit1 = edit_line node.name.to_s , width:50
         p 'Attr: ' + node.name.to_s + ' value:' + node.value
         if node.is_a? (Nokogiri::XML::Attr)
           edit1.text = node.value
           edit1.change do
             node.parent.set_attribute(node.name.to_s, self.text)

           end

         end

       end

      end

    end
  end
end