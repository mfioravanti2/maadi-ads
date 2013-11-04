

require 'nokogiri'

module Maadi
  module UI
    class MaadiXMLElement < Nokogiri::XML::Node

      def initialize(name, document)
        super(name, document)
      end



    end
  end
end
