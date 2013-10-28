# Author : Scott Forest Hull II (shull2013@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 10/19/2013
# File   : XMLUI.rb
#
# Summary: Represents two components:  The root Shoes.app
#          and the XMLUI main widget class.  This class
#          dynamically creates a UI from an XML file.

require_relative '../../lib/core/generic/generic'

require 'rubygems'
require 'nokogiri'
require 'green_shoes'
require_relative 'Xmlelementwrapper'
require_relative 'Xmlattributewrapper'

module Maadi
  module UI
    class XMLUI < Shoes::Widget

      #Attributes
      attr_accessor :elements, :xmlObject, :saveButton, :loadButton, :mainFlow, :first

      #The constructor.  Takes one argument
      #xmlObj - a root Nokogiri XML Object
      def initialize opts={}
        @xmlObject = opts[:xmlObj]

        @first = 0
        #Setup buttons
        setupButtons
        @mainFlow = flow do
          #create UI elements
          @elements = createUIElements(@xmlObject)
        end

      end

      #Creates save and load buttons
      def setupButtons
        @saveButton = button 'SaveFile'
        @loadButton = button 'LoadFile'

        #Create a save button
        @saveButton.click do

          #Get the file.  Overwrites file if necessary
          f = File.open('test.xml', 'w') { |f| f.print(@xmlObject.to_xml) }

        end

        #Create a load button
        @loadButton.click do
          p 'Asking to open a file'
          #Ask the user for a file path.
          filePath = ask_open_file

          if filePath == nil
            alert 'File not loaded:  no file selected.'
          elsif !filePath.include?(".xml")
            alert 'File not loaded: not an xml file.'
          else
            #see if the file exists

            #Verify if the file exists
            if !File.exists?(filePath)
              alert 'File not loaded: file does not exist!'
            else

              #open the file and store the object
              file = File.open(filePath.to_s)
              @xmlObject = nil
              @xmlObject = Nokogiri::XML(file)

              #Clear out the UI and reload
              @elements.teardown
              @mainFlow.clear
              @mainFlow = flow do
                #create UI elements
                @elements = createUIElements(@xmlObject)
              end

              #Close the file
              file.close
            end
          end
        end
      end

      #Creates the Internal UI.
      #xmlElement - the Nokogiri XMLElement class
      def createUIElements (xmlElement)

        if xmlElement.is_a? (Nokogiri::XML::Node)
          p 'XMLElement ' + xmlElement.name.to_s
          wrapper = nil

          #Create a xmlelementwrapper widget.
          wrapper = xmlelementwrapper :xmlElement => xmlElement, :doc => @xmlObject

          flow1 = flow :margin_left => 10 do


            #For each child, if it is an xml element recursively add to UI
            xmlElement.children.each do |node|

              if node.is_a? (Nokogiri::XML::Element)
                element = createUIElements(node)
                element.hideSelf()
                wrapper.addXMLElement(element)
              end
            end
          end


          #Set the flow
          wrapper.setFlow(flow1)

          return wrapper
        end

      end


    end

    #Root shoes app
    Shoes.app :title => "Green Shoes XML Editor", :width=> 800, :height =>600 do

      background whitesmoke

      #Open a file to start her up.
      @fXML = File.open("test.xml")
      @xmlObj = Nokogiri::XML(@fXML)
      @fXML.close


      p 'File grabbed: ' + @xmlObj.name.to_s

      @rootFlow = flow do
        para 'The content below represents an XML File'


        #Create the XML UI sub pieces
        @interface=xmlui({:xmlObj => @xmlObj})

      end
    end

  end
end


