require_relative '../../lib/core/generic/generic'

require 'rubygems'
require 'nokogiri'
require 'green_shoes'


module Maadi
  module Application
    module UI

      class UIXMLElementNode

        def initialize (xmlElement)

          if xmlElement.is_a? (Nokogiri::XML::Element)

          end


        end

      end
      class XMLUI < Shoes::Widget



         def initialize opts={}
             @boxCount = 0;
             @xMLObject = opts[:xmlObj]
             p 'initialize: ' + @xMLObject.name.to_s
         end

         def createUIElements (xmlElement)

           xmlElement.children.each do |node|
             flow1 = flow :margin_left => 10 do
               keyValuePair(node)
               #Make all the children
               xmlElement.attribute_nodes.each do |attribute|
                 keyValuePair(attribute)
               end

               if node.is_a?(  Nokogiri::XML::Element )
                 stack do
                   createUIElements(node)
                 end
               end

               button1 = button 'show'
               button1.click do
                 if button1.text == "show"
                   p 'Inside toggle'
                   p button1.parent
                   button1.parent.contents.each do |child|
                     p child.to_s
                     child.show
                   end
                  #button1.text = "hide"
                 else
                  #parent.toggle
                  #button1.text = 'show'
                 end
               end

              end

             if xmlElement.name.to_s == "xml"
               p 'hit'
             elsif xmlElement.name.to_s == "document"
             elsif xmlElement.name.to_s == "tests"
             else
               p 'Toggling for: ' + xmlElement.name.to_s
               flow1.toggle
             end

           end

         end

         def keyValuePair(node)
              @boxCount = @boxCount+1;
             inscription node.name.to_s, width: 50
             edit1 = edit_line node.name.to_s , width:50
             if node.is_a? (Nokogiri::XML::Attr)
               edit1.text = node.value
               edit1.change do
                 #node.parent.set_attribute(node.name.to_s, self.text)

               end

             end

         end

      end




Shoes.app :title => "Green Shoes XML Editor" do

  @rootFlow = flow do
    para 'The content below represents an XML File'

  end

  fXML = File.open( "test.xml" )
  xmlObj = Nokogiri::XML(fXML)
  fXML.close


  p 'File grabbed: ' + xmlObj.name.to_s

  @interface=xmlui({:xmlObj=>xmlObj})

  @interface.createUIElements(xmlObj)

  para 'Finished'
end

    end
  end
end


