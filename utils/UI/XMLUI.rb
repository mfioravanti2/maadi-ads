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

         attr_accessor :elements, :xmlObject

         def initialize opts={}
             @xMLObject = opts[:xmlObj]

             @elements = createUIElements(@xMLObject)
         end

         def createUIElements (xmlElement)

           p 'XMLElement ' + xmlElement.name.to_s
           wrapper = nil
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


      Shoes.app :title => "Green Shoes XML Editor" do



        fXML = File.open( "test.xml" )
        xmlObj = Nokogiri::XML(fXML)
        fXML.close


        p 'File grabbed: ' + xmlObj.name.to_s

        @rootFlow = flow do
          para 'The content below represents an XML File'

          @interface=xmlui({:xmlObj=>xmlObj})

        end

        para 'Finished'
      end

    end
  end
end


