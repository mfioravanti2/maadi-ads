# Author : Scott Forest Hull II (shull2013@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 10/19/2013
# File   : Xmlelementwrapper.rb
#
# Summary: A wrapper for holding data and ui widgets
#          regarding representations for xml elements.

require 'nokogiri'
require 'green_shoes'

require_relative 'Xmlattributewrapper'
module Maadi
  module UI
    class Xmlelementwrapper  < Shoes::Widget

        #Attributes
       attr_accessor :xmlElement, :text, :button, :xmlAttributeWraps, :xmlElementWraps, :addRemoveButton, :doc, :rootFlow

       #The constructor
       #xmlElement - the Nokogiri representation of an XML element.
       def initialize opts={}

         if opts[:xmlElement].is_a? ( Nokogiri::XML::Node) and opts[:doc].is_a? ( Nokogiri::XML::Node)

           #Create an XML element
          @xmlElement = opts[:xmlElement]
          @doc = opts[:doc]
          @xmlElementWraps = Array.new()
          @xmlAttributeWraps = Array.new()

          #Create addRemoveButton for XMLElement
          setupAddAndRemoveButtons

          #Create the text widget
          @text = inscription @xmlElement.name.to_s, width:75

          #Make all the children
          @xmlElement.attribute_nodes.each do |attribute|
            xmlAttrWrap =  createXMLAttribute(attribute)
            xmlAttrWrap.hideSelf
            xmlAttributeWraps.push(xmlAttrWrap)
          end

          #Create a check box and add and remove buttons
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

       #Setup the XML Element add and remove buttons
       def setupAddAndRemoveButtons ()
         @addRemoveButton = list_box items: ["", "+", "-"], width: 30

         @addRemoveButton.change do
           if @addRemoveButton.text == "+"
             prompt = ask ("Please enter a new child element.")

             if prompt != nil and @rootFlow != nil
               #Create the node
               node = Nokogiri::XML::Node.new(prompt, @doc)
               #Add to Nokogiri XML Element
               @xmlElement << node

               #Create a wrapper and add it to the flow
               wrapper = nil
               @rootFlow.append do
                 #create a new class and add it
                 wrapper = xmlelementwrapper :xmlElement=> node, :doc=>@doc

                 #create a new flow for the children
                 flow1 = flow :margin_left => 10 do
                   #Do nothing
                 end
                 wrapper.setFlow(flow1)

                 #Add created child to wrapper
                 addXMLElement(wrapper)
               end

               #Reset the text
               @addRemoveButton.text = "";

             end

           elsif @addRemoveButton.text == "-"

             #create list of xml names
             i = 0
             name = ""
             nameList = Array.new
             @xmlElementWraps.each do |child|
               tempName = i.to_s + ". " + child.getXMLElement.name.to_s
               name = name + "\n" + tempName
               i = i + 1
               nameList.push(tempName)
             end

             #Ask the user to input the xml element to remove
             prompt = ask "Which element would you like to delete?  Please enter a number\n and the full name listed below:" + name, width: 200, height:500
             p 'The prompt is: ' + prompt
             p 'The prompt is: ' + prompt
             p 'The prompt is: ' + prompt
             p 'The prompt is: ' + prompt
             p 'The prompt is: ' + prompt
             p 'The prompt is: ' + prompt

             #get the index.  If it exists, then time to remove
             i = 0
             @xmlElementWraps.each do |child|
                if prompt == (i.to_s + ". " + child.getXMLElement.name.to_s)

                  p 'Tearing down: ' + child.getXMLElement.name.to_s
                  child.teardown


                end
                i = i + 1
             end

           end
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
          @addRemoveButton.hide
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
         @addRemoveButton.show
       end

       def setFlow (flow)
         @rootFlow = flow
       end

       #A deconstructor method
        def teardown
          @check.remove
          @text.remove
          @addRemoveButton.remove

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