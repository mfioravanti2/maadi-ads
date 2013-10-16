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
         @xmlElementWraps = Array.new()

         @xmlAttributeWraps = Array.new()

         @text = inscription @xmlElement.name.to_s, width:75

         #Make all the children
         @xmlElement.attribute_nodes.each do |attribute|
           xmlAttrWrap =  createXMLAttribute(attribute)
           xmlAttrWrap.hideSelf
           xmlAttributeWraps.push(xmlAttrWrap)
         end

         @check = check

         @check.click do
          if @check.checked?
            @xmlAttributeWraps.each do |child|
              child.showSelf
            end

            #iterate over Elements and show
            @xmlElementWraps.each do |child|
              child.showSelf
            end


          else
            @xmlAttributeWraps.each do |child|
              child.hideSelf
            end

            #iterate over Elements and hide
            @xmlElementWraps.each do |child|
              child.hideSelf
            end
          end
         end

         p 'XMLElement node created for: ' + @xmlElement.name.to_s
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

       def hideSelf
          @check.hide
          @text.hide


       end

       def showSelf
         @check.show
         @text.show
       end

      end

    end
  end
end