# Author : Mark Fioravanti (mfioravanti@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : Example.rb
# License: Creative Commons Attribution
#
# Summary: This is a Monitor for the Microsoft Windows Operating System

require_relative 'factory'
require_relative '../../core/helpers'

class Array
  def integer_sum
    sum = 0
    self.map{|x| sum += x.to_i}
    return sum
  end
end

module Maadi
  module Monitor
    class Windows < Monitor

      def initialize
        super('Windows')

        @ps_where = `where powershell`.chomp
        # puts @ps_where if is_ok?

        initial_data
        #update_data

        puts " Total Physical Memory: #{@config['hw']['memory']['physical']['total']}"
        puts " Total Logical Processors: #{@config['hw']['cpu']['processors']}"
      end

      def is_ok?
        return ( @ps_where =~ /powershell\.exe$/i )
      end

      def parse_powershell( result, keyword )
        value = Array.new

        lines = result.split(/\r?\n/)
        lines.each do |line|
          if line =~ /:/
            info = line.split(/:/)
            ps_property = info[0].strip
            ps_value = info[1].strip

            #puts "#{ps_property} = #{ps_value}"

            if ps_property.downcase == keyword.downcase
              #puts ps_value
              value.push ps_value
            end
          end
        end

        return value
      end

      def initial_data
        if is_ok?
          ps_data = `powershell -command "get-wmiobject win32_physicalmemory | select-object Capacity | fl"`.chomp
          ps_items = parse_powershell(ps_data, 'capacity')
          @config['hw']['memory']['physical']['total'] = ps_items.integer_sum

          ps_data = `powershell -command "get-wmiobject win32_processor | select-object NumberOfLogicalProcessors | fl"`.chomp
          ps_items = parse_powershell(ps_data, 'NumberOfLogicalProcessors')
          @config['hw']['cpu']['processors'] = ps_items.integer_sum

          ps_data = `powershell -command "get-wmiobject win32_operatingsystem | select-object TotalVirtualMemorySize,TotalVisibleMemorySize,Version,ServicePackMajorVersion,ServicePackMinorVersion | fl"`.chomp
          ps_items = parse_powershell(ps_data, 'TotalVirtualMemorySize')
          @config['hw']['memory']['virtual']['total'] = ps_items.integer_sum

          ps_items = parse_powershell(ps_data, 'TotalVisibleMemorySize')
          #@config['hw']['memory']['virtual']['total'] = ps_items.integer_sum

          ps_items = parse_powershell(ps_data, 'Version')
          @config['os']['platform']['version'] = ps_items.join('')

          ps_items = parse_powershell(ps_data, 'ServicePackMajorVersion')
          @config['os']['platform']['update'] = "SP" + ps_items[0].to_s
        end
      end

      def update_data
        if is_ok?
          #@ps_data = `powershell -command "get-process"`.chomp
          #puts @ps_data

          @ps_data = `powershell -command "get-wmiobject win32_processor | select-object LoadPercentage | fl"`.chomp
          puts @ps_data

          @ps_data = `powershell -command "get-wmiobject win32_operatingsystem | select-object FreePhysicalMemory,FreeVirtualMemory | fl"`.chomp
          puts @ps_data
        end
      end
    end
  end
end