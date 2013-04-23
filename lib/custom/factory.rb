# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : factory.rb
#
# Summary: This is the general factory object which will provide
#          a list of files from the local custom extensions directories
#          an based on either a list of files or a single file it will
#          create instances of those objects for use within the
#          application.

require_relative '../core/helpers'

$bin_path = '../lib/custom/'

module Maadi
  class Factory

    def Factory::products( type )
      listing = Array.new

      Dir[$bin_path + type + '/*.rb'].each do |file|
        if  ( file =~ /\.rb$/i ) && !( file =~ /factory\.rb$/i )
          file_name = File.basename(file, '.*')

          listing.push( file_name )
        end
      end

      return listing
    end

    def Factory::manufacture( type, product, messaging = true )

      if product.instance_of?( String )
          Dir[$bin_path + type + '/*.rb'].each do |file|
            if  ( file =~ /\.rb$/i ) && !( file =~ /factory\.rb$/i )
              file_name = File.basename(file, '.*')

              if file_name.downcase == product.downcase
                require_relative type + '/' + file_name

                begin
                  class_name = Object.const_get('Maadi').const_get(type).const_get(file_name)
                  class_obj = class_name.new()

                  Maadi::post_message(:More, "Factory created class #{class_obj.class}") if messaging

                  return class_obj
                rescue
                  Maadi::post_message(:Warn, "Unable to dynamically create Maadi::#{file_name}") if messaging
                end
              end
            end
          end
      elsif product.instance_of?( Array )
          listing = Array.new

          Dir[$bin_path + type + '/*.rb'].each do |file|
            if  ( file =~ /\.rb$/i ) && !( file =~ /factory\.rb$/i )
              file_name = File.basename(file, '.*')

              product.each do |item|
                if file_name.downcase == item.downcase
                 require_relative type + '/' + file_name

                  begin
                    class_name = Object.const_get('Maadi').const_get(type).const_get(file_name) if messaging
                    class_obj = class_name.new()

                    Maadi::post_message(:More, "Factory created class #{class_obj.class}")

                    listing.push( class_obj )
                  rescue
                    Maadi::post_message(:Warn, "Unable to dynamically create Maadi::#{file_name}") if messaging
                  end
                end
              end

            end
          end

          return listing
      end

      return nil
    end

  end
end