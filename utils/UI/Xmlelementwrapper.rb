require 'rubygems'
require 'nokogiri'
require 'green_shoes'

require_relative 'Xmlattributewrapper'
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
           xmlAttributeWraps.push(createXMLAttribute(attribute))
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

       def createXMLAttribute(node)
         return xmlattributewrapper :xmlAttribute =>node


       end

      end

    end
  end
end