
require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Application
    class RubyStack < Application

      def initialize
        super('RubyStack')

        @rStack = nil
      end

      def supported_domains
        return %w(ADS-STACK ADS-AXIOMATIC-STACK ALGEBRAICADS-STACK)
      end

      def prepare
        begin
          @rStack = nil

        rescue => e
          Maadi::post_message(:Warn, "Application (#{@type}:#{@instance_name}) was unable to initialize (#{e.message}).")
        end

        super
      end

      def supports_step?( step )
        if Maadi::Procedure::Step.is_step?( step )
          return %w(PUSH POP SIZE ATINDEX NULCONSTRUCT NONNULCONSTRUCT DETAILS).include?( step.id )
        end

        return false
      end

      def execute( test_id, procedure )
        results = Maadi::Procedure::Results.new( test_id.to_i, 0, "#{@type}:#{@instance_name}", nil )


          if procedure.is_a?( ::Maadi::Procedure::Procedure )
            results.proc_id = procedure.id

            procedure.steps.each do |step|
              if step.target == execution_target
                if supports_step?( step )
                  # lValue is the item that is modified (usually the stack)
                  lValue = -1
                  lType = 'TEXT'
                  # rValue is the item that is not modified during an operation
                  rValue = -1
                  rType = 'TEXT'
                  bSuccess = false
                  bError = false

                  if @rStack != nil
                    Maadi::post_message(:Info, "#{@type}:#{@instance_name} Pre-#{step.id} Stack: ' #{@rStack.inspect.to_s}",3)
                  end

                  begin
                    case step.id
                      when 'PUSH'
                        rValue = step.get_parameter_value('[RVALUE]')

                        if @rStack != nil
                          @rStack.push rValue
                          lValue = @rStack.size
                          lType = 'INTEGER'

                          bSuccess = true
                          bError = false
                        else
                          lValue = rValue = 'PUSH Failed, Stack not instantiated'
                          bSuccess = false
                          bError = true
                        end
                      when 'POP'
                        if @rStack != nil
                          if @rStack.size > 0
                            lValue = @rStack.pop
                            lType = 'INTEGER'
                            rValue = @rStack.size
                            rType = 'INTEGER'


                            bSuccess = true
                            bError = false
                          else
                            lValue = rValue = 'POP Failed, Stack is empty'
                            lType = 'TEXT'
                            bSuccess = false
                            bError = true
                          end
                        else
                          lValue = rValue = 'POP Failed, Stack not instantiated'
                          lType = 'TEXT'
                          bSuccess = false
                          bError = true
                        end
                      when 'SIZE'
                        if @rStack != nil
                          lValue = @rStack.size
                          lType = 'INTEGER'

                          bSuccess = true
                          bError = false
                        else
                          lValue = rValue = 'SIZE Failed, Stack not instantiated'
                          lType = rType = 'TEXT'
                          bSuccess = false
                          bError = true
                        end
                      when 'ATINDEX'
                        index = step.get_parameter_value('[INDEX]')

                        if @rStack != nil
                          if @rStack.size > 0
                            if index.to_i < @rStack.size
                              rValue = @rStack[index.to_i]
                              rType = 'INTEGER'
                              lValue = @rStack.size
                              lType = 'INTEGER'

                              bSuccess = true
                              bError = false
                            else
                              lValue = rValue = 'ATINDEX Failed, requested index is larger than stack size'
                              lType = rType = 'TEXT'
                              bSuccess = false
                              bError = true
                            end
                          else
                            lValue = rValue = 'ATINDEX Failed, Stack is empty'
                            lType = rType = 'TEXT'
                            bSuccess = false
                            bError = true
                          end
                        else
                          lValue = rValue = 'ATINDEX Failed, Stack not instantiated'
                          lType = rType = 'TEXT'
                          bSuccess = false
                          bError = true
                        end
                      when 'NULCONSTRUCT'
                        @rStack = Array.new()
                        lValue = rValue = @rStack.size
                        lType = rType = 'INTEGER'

                        if @rStack != nil
                          bSuccess = true
                          bError = false
                        else
                          bSuccess = false
                          bError = true
                        end

                      when 'NONNULCONSTRUCT'
                        @rStack = Array.new()
                        lValue = rValue = @rStack.size
                        lType = rType = 'INTEGER'

                        if @rStack != nil
                          bSuccess = true
                          bError = false
                        else
                          bSuccess = false
                          bError = true
                        end
                      when 'DETAILS'
                        if @rStack != nil
                          lValue = @rStack.to_s
                          lType = 'TEXT'

                          bSuccess = true
                          bError = false
                        else
                          lValue = rValue = 'DETAILS Failed, Stack not instantiated'
                          lType = rType = 'TEXT'

                          bSuccess = false
                          bError = true
                        end

                      else
                    end

                    #Print some meaningful information
                    if @rStack != nil
                      Maadi::post_message(:Info, "#{@type}:#{@instance_name} Post-#{step.id} Stack: ' #{@rStack.inspect.to_s}",3)
                    end
                    if lValue != -1
                      Maadi::post_message(:Info, "#{@type}:#{@instance_name} #{step.id} lValue: ' #{lValue.to_s}",3)
                    end
                    if rValue != -1
                      Maadi::post_message(:Info, "#{@type}:#{@instance_name} #{step.id} rValue: ' #{rValue.to_s}", 3)
                    end

                    case step.look_for
                      when 'NORECORD'
                      when 'LVALUE'
                        results.add_result( Maadi::Procedure::Result.new( step, lValue.to_s, lType, ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                      when 'RVALUE'
                        results.add_result( Maadi::Procedure::Result.new( step, rValue.to_s, rType, ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                      when 'CHANGES'
                        results.add_result( Maadi::Procedure::Result.new( step, '', 'TEXT', ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                      when 'COMPLETED'
                        results.add_result( Maadi::Procedure::Result.new( step, '', 'TEXT', ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                      else
                        results.add_result( Maadi::Procedure::Result.new( step, step.look_for, 'TEXT', 'UNKNOWN' ))
                    end
                  rescue => e
                    Maadi::post_message(:Warn, "Application (#{@type}:#{@instance_name}) encountered an error (#{e.message}).")
                    results.add_result( Maadi::Procedure::Result.new( step, e.message, 'TEXT', 'EXCEPTION' ))
                  end
                else
                  Maadi::post_message(:Warn, "Application (#{@type}:#{@instance_name}) encountered an unsupported step (#{procedure.id}, #{step.id}).")
                end
              end
            end
          end


        return results
      end

      def teardown
        @rStack = nil

        super
      end
    end
  end
end