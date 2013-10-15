
require 'green_shoes'
require 'nokogiri'


Shoes.app :width => 1000, :height => 500 do
  i = 0;
  flow :margin_left => 10 do
     1000.times do
       para1 = para 'bar', width: 100
       edit1 = edit_line('foo').change do
         p 'Stuff'
       end


      para1.toggle


       i = i + 1
    end
  end

end