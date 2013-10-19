require_relative '../../lib/core/generic/generic'

require 'rubygems'
require 'nokogiri'
require 'green_shoes'
require_relative 'Xmlelementwrapper'
require_relative 'Xmlattributewrapper'

module Maadi
  module Application
    module UI

      class XMLUI < Shoes::Widget

         attr_accessor :elements, :xmlObject, :saveButton, :loadButton, :xmlFile, :mainFlow, :first

         def initialize opts={}
             @xmlObject = opts[:xmlObj]
             @xmlFile = opts[:xmlFile]

             @first = 0
             #Setup buttons
             setupButtons

             #create UI elements
             @elements = createUIElements(@xmlObject)

         end

         def setupButtons
           @saveButton  = button 'SaveFile'
           @loadButton = button 'LoadFile'

           @saveButton.click do
             p 'Trying to save file: ' + @xMLObject.name.to_s
             f = File.open('test.xml', 'w') { |f| f.print(@xMLObject.to_xml) }

           end

           @loadButton.click do
             filePath = ask_open_file

             p 'Filepath: ' + filePath
             if filePath == ""
               alert 'You need to enter a file name!'
             elsif !filePath.include?(".xml")
              alert 'That is not an xml file'
             else
               #see if the file exists


               if !File.exists?(filePath)
                 alert 'File doesnt exist!'
               else
                 @xmlFile = File.open( filePath.to_s )
                 @xmlObject = nil
                 @xmlObject = Nokogiri::XML(@xmlFile)

                 @mainFlow.clear
                 @elements.teardown
                 @elements = createUIElements(@xmlObject)


                 @xmlFile.close
               end
             end



           end
         end

         def createUIElements (xmlElement)

           p 'XMLElement ' + xmlElement.name.to_s
           wrapper = nil

           if @first == 0
             @first == 1
             @mainFlow = flow :margin_left => 10 do

               wrapper = xmlelementwrapper :xmlElement=> xmlElement

               xmlElement.children.each do |node|

                 if node.is_a? ( Nokogiri::XML::Element)
                   element = createUIElements(node)
                   element.hideSelf()
                   wrapper.addXMLElement(element)
                 end
               end
             end

             return wrapper

           else

             #Bad fix me later
             flow :margin_left => 10 do

               wrapper = xmlelementwrapper :xmlElement=> xmlElement

               xmlElement.children.each do |node|

                 if node.is_a? ( Nokogiri::XML::Element)
                   element = createUIElements(node)
                   element.hideSelf()
                   wrapper.addXMLElement(element)
                 end
               end
             end

             return wrapper
           end



           end


      end


      Shoes.app :title => "Green Shoes XML Editor" do



        @fXML = File.open( "test.xml" )
        @xmlObj = Nokogiri::XML(@fXML)
        @fXML.close


        p 'File grabbed: ' + @xmlObj.name.to_s

        @rootFlow = flow do
          para 'The content below represents an XML File'



          @interface=xmlui({:xmlObj=>@xmlObj, :xmlFile=>@fXML})

        end

        para 'Finished'
      end

    end
  end
end


