# Author : Scott Forest Hull II (shull2013@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 10/19/2013
# File   : Xmlelementwrapper.rb
#
# Summary: A wrapper for holding data and ui widgets
#          regarding representations for xml elements.


require 'rubygems'
require 'nokogiri'
require 'green_shoes'

require_relative 'Xmlattributewrapper'
module Maadi
    module UI
      class Xmlelementwrapper < Shoes::Widget

        #Attributes
       attr_accessor :xmlElement, :text, :button, :xmlAttributeWraps, :xmlElementWraps

       #The constructor
       #xmlElement - the Nokogiri representation of an XML element.
       def initialize opts={}

         if opts[:xmlElement].is_a? ( Nokogiri::XML::Node)

           #Create an XML element
          @xmlElement = opts[:xmlElement]
          @xmlElementWraps = Array.new()
          @xmlAttributeWraps = Array.new()

          #Create the text widget
          @text = inscription @xmlElement.name.to_s, width:75

          #Make all the children
          @xmlElement.attribute_nodes.each do |attribute|
            xmlAttrWrap =  createXMLAttribute(attribute)
            xmlAttrWrap.hideSelf
            xmlAttributeWraps.push(xmlAttrWrap)
          end

          #Create a check box
          @check = check

          #If clicked, hide the information or show
          @check.click do

            #Show
            if @check.checked?
              @xmlAttributeWraps.each do |child|
                child.showSelf
              end

              #iterate over Elements and show
              @xmlElementWraps.each do |child|
                child.showSelf
              end

            #Hide
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
         else
        end
       end

       #Returns the xmlElement attribute.
       def getXMLElement
         return @xmlElement
       end

       #Returns the Shoes UI text box
       def getText
         return @text
       end

       #Returns the Shoes UI check box
       def getCheck
         return @check
       end

       #Returns the sibling XmlElementWrappers
       def getXMLElements
         return @xmlElementWraps
       end

       #Adds an XMLElementWrap
       def addXMLElement(xmlElementWrap)
         if xmlElementWrap.is_a?(Maadi::UI::Xmlelementwrapper)
          @xmlElementWraps.push(xmlElementWrap)
         end
       end

       #Adds an xmlAttributeWrap
       def addAttribute(xmlAttributeWrap)
         if xmlAttributeWrap.is_a(Maadi::UI::Xmlattributewrapper)
           @xmlAttributeWraps.push(xmlAttributeWrap)
         end
       end

       #Creates an XMLAttributeWrapper from a Nokogiri Attribute
       def createXMLAttribute(node)
         return xmlattributewrapper :xmlAttribute =>node

       end

       #Hides the widget
       def hideSelf
          @check.hide
          @check.checked = false;
          @text.hide
          @xmlAttributeWraps.each do |child|
            child.hideSelf
          end

          #iterate over Elements and hide
          @xmlElementWraps.each do |child|
            child.hideSelf
          end

       end

       #Shows the widget
       def showSelf
         @check.show
         @text.show
       end

       #A deconstructor method
        def teardown
          @check.remove
          @text.remove

          @xmlAttributeWraps.each do |child|
            child.teardown
          end

          #iterate over Elements and hide
          @xmlElementWraps.each do |child|
            child.teardown
          end

        end
      end

    end
end