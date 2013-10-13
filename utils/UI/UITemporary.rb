
require 'green_shoes'
require 'nokogiri'


Shoes.app :width => 1000, :height => 500 do

  flow :margin_left => 10 do
    para "XMLElementName", width:200
    edit_line "A"
    edit_line "B"

    flow :margin_left => 10 do
      edit_line "C"
    end
  end

end