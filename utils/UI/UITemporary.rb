
require 'green_shoes'
require 'nokogiri'

class UITemporary < Shoes::Widget
  def initialize
    stack stroke: red, fill: blue do
      para 'stuff'
      r = star(80, 65, 5, 60, 40)
      r.style(stroke: blue, fill: black)
      star(50, 60, 5, 25, 10)
      star(110, 60, 5, 25, 10)
      a = arc(80, 100, 100, 20, 90, 180)
    end
  end
end

Shoes.app do

  fXML = File.open( "test.xml" )
  @xMLObject = Nokogiri::XML(fXML)
  fXML.close

  flow do
    @ui = UITemporary
  end



end