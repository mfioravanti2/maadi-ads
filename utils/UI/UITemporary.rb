


require 'green_shoes'
module Maadi
  module Application
    module UI
      class UITemporary
        def initialize

          Shoes.app(title: "Maadi XML Editor", width: 600, height:400)  do

            @numAttributes = ['Attribute1', 'Attribute2', 'Attribute3']
            @editLines = []
            i = 0
            stack margin: 1 do
              background gainsboro
              subtitle "Basic XML editing support enabled"
            end
            while (i < @numAttributes.size)


              flow do
                para 'First Element'
                line = edit_line  'Foo'
                caption 'First attribute'
                line2 = edit_line ' bar'
                caption 'Ada'
                @editLines.push(line)
                @editLines.push(line2)
              end
              i = i + 1
            end
          end


      end
      end
    end
  end
end

foo = Maadi::Application::UI::UITemporary.new()