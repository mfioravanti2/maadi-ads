require 'green_shoes'
require 'nokogiri'
class Prompt < Shoes::Widget
  def initialize opts={}
    @top=opts[:top]
    @left=opts[:left]
    @width=opts[:width]
    @prom=flow :top=>@top, :left=>@left, :width=>@width do
      background red
    end
  end
  def print(msg)
    @prom.append do
      para msg
    end
  end

  def createUIElements (xmlElement)

    xmlElement.children.each do |node|
      flow do
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

    flow do
      para node.name.to_s
      edit_line node.name.to_s
    end
  end
end

Shoes.app :title => "Test" do
  @el=edit_line
  button "print"do
    @interface.print(@el.text)
  end
  @interface=prompt({:top=>50, :left=>20, :width=>100})
  @rootFlow = flow do
    para 'more stuff'
  end

  fXML = File.open( "test.xml" )
  @xMLObject = Nokogiri::XML(fXML)
  fXML.close

  @interface.createUIElements(@xMLObject)
  para 'Finished'
end