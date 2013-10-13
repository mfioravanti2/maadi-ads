require_relative '../../lib/core/generic/generic'

require 'rubygems'
require 'nokogiri'
require 'green_shoes'


module Maadi
  module Application
    module UI
      class XMLUI < Shoes::Widget



         def initialize opts={}

             @xMLObject = opts[:xmlObj]
             p 'initialize: ' + @xMLObject.name.to_s
         end

         def createUIElements (xmlElement)

           xmlElement.children.each do |node|
             flow :margin_left => 10 do
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

             end



           end
         end

         def keyValuePair(node)

             inscription node.name.to_s, width: 50
             edit1 = edit_line node.name.to_s , width:50
             if node.is_a? (Nokogiri::XML::Attr)
               edit1.text = node.value
               edit1.change do
                 node.parent.set_attribute(node.name.to_s, self.text)
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


