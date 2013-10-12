require_relative '../../lib/core/generic/generic'

require 'rubygems'
require 'nokogiri'
require 'green_shoes'
require_relative 'UITemporary'

module Maadi
  module Application
    module UI
      class XMLUI



         def initialize(xMLObject)
             p 'initialize: ' + xMLObject.name.to_s
             @xMLObject = xMLObject
             createUI
         end



         def createUI


           UITemporary


         end

         def createUIElements (xmlElement)
           xmlElement.children.each do |node|
             p node.name.to_s

             @rootFlow.app do
               @rootFlow.append do
                 flow do

                   edit_line = node.name.to_s
                   if node.is_a?(  Nokogiri::XML::Element )
                     createUIElements(node)
                   end
                 end

               end

             end
           end
         end


      end


    end
  end
end




