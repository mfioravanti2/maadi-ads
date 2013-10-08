# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - Algebraic Data Structures
# Date   : 10/01/2013
# File   : validate.rb
#
# Summary: Builder object to validate the state of a procedure

require_relative '../../../procedure/procedure'

module Maadi
  module Expert
    module Builder
      module Conditions
        class ConditionExists
          attr_accessor :type, :look_for, :objects, :keys, :path

          def initialize(node)
            @path = Hash.new

            if node != nil
              @look_for = node['look_for']
              @objects = node['objects'].split(':')
              @keys = node['keys'].split(':')

              0.upto(@objects.length - 1) do |index|
                @path[@objects[index]] = @keys[index]
              end

              puts @path.inspect
            end
          end

          def test( procedure, expert, model )
            if Maadi::Procedure::Procedure.is_procedure?( procedure )
              proc = nil
              step = nil
              param = nil

              @path.each do |key,value|
                puts "Testing: #{key} = #{value}"
                case key.downcase
                  when 'procedure'
                    proc = procedure
                    if @look_for.downcase == 'procedure'
                      return Maadi::Procedure::Procedure.is_procedure?( procedure, value )
                    else
                      unless Maadi::Procedure::Procedure.is_procedure?( procedure, value )
                        return false
                      end
                    end
                  when 'step'
                    step = proc.get_step( value )
                    if @look_for.downcase == 'step'
                      return Maadi::Procedure::Step.is_step?( step, value )
                    else
                      unless Maadi::Procedure::Step.is_step?( step, value )
                        return false
                      end
                    end
                  when 'parameter'
                    param = step.get_parameter( value )
                    if @look_for.downcase == 'parameter'
                      if Maadi::Procedure::Parameter.is_parameter?( param, value )
                        if param.value != ''
                          return true
                        end
                      end

                      return false
                    else
                      unless Maadi::Procedure::Step.is_step?( param, value )
                        return false
                      end
                    end
                end
              end
            end

            return false
          end
        end
      end
    end
  end
end