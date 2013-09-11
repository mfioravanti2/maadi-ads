
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
        return %w(ADS-STACK)
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
        if step != nil
          if step.is_a?( ::Maadi::Procedure::Step )
            case step.id
              when 'PUSH'
                return true
              when 'POP'
                return true
              when 'SIZE'
                return true
              when 'ATINDEX'
                return true
              when 'NULCONSTRUCT'
                return true
              when 'NONNULCONSTRUCT'
                return true
              else
            end
          end
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
                  # rValue is the item that is not modified during an operation
                  rValue = -1
                  bSuccess = false
                  bError = false

                  begin
                    case step.id
                      when 'PUSH'
                        rValue = step.get_parameter_value('[RVALUE]')

                        if @rStack != nil
                          @rStack.push rValue
                          lValue = @rStack.size

                          bSuccess = true
                          bError = false
                        else
                          lValue = rValue = 'PUSH Failed, RubyStack not instantiated'
                          bSuccess = false
                          bError = true
                        end
                      when 'POP'
                        if @rStack != nil
                          if @rStack.size > 0
                            lValue = @rStack.pop
                            rValue = @rStack.size

                            bSuccess = true
                            bError = false
                          else
                            lValue = rValue = 'POP Failed, RubyStack is empty'
                            bSuccess = false
                            bError = true
                          end
                        else
                          lValue = rValue = 'POP Failed, RubyStack not instantiated'
                          bSuccess = false
                          bError = true
                        end
                      when 'SIZE'
                        if @rStack != nil
                          lValue = @rStack.size

                          bSuccess = true
                          bError = false
                        else
                          lValue = rValue = 'SIZE Failed, RubyStack not instantiated'
                          bSuccess = false
                          bError = true
                        end
                      when 'ATINDEX'
                        index = step.get_parameter_value('[INDEX]')

                        if @rStack != nil
                          if @rStack.size > 0
                            if index.to_i < @rStack.size
                              lValue = @rStack[index.to_i]
                              rValue = @rStack.size
                            else
                              lValue = rValue = 'ATINDEX Failed, requested index is larger than stack size'
                              bSuccess = false
                              bError = true
                            end
                          else
                            lValue = rValue = 'ATINDEX Failed, RubyStack is empty'
                            bSuccess = false
                            bError = true
                          end
                        else
                          lValue = rValue = 'ATINDEX Failed, RubyStack not instantiated'
                          bSuccess = false
                          bError = true
                        end
                      when 'NULCONSTRUCT'
                        @rStack = Array.new()
                        lValue = rValue = @rStack.size

                        if @rStack != nil
                          bSuccess = true
                          bError = false
                        end
                      when 'NONNULCONSTRUCT'
                        @rStack = Array.new()
                        lValue = rValue = @rStack.size

                        if @rStack != nil
                          bSuccess = true
                          bError = false
                        end
                      else
                    end

                    case step.look_for
                      when 'NORECORD'
                      when 'LVALUE'
                        results.add_result( Maadi::Procedure::Result.new( step, lValue.to_s, 'TEXT', ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                      when 'RVALUE'
                        results.add_result( Maadi::Procedure::Result.new( step, rValue.to_s, 'TEXT', ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                      when 'CHANGES'
                        results.add_result( Maadi::Procedure::Result.new( step, '', 'TEXT', ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                      when 'COMPLETED'
                        results.add_result( Maadi::Procedure::Result.new( step, '', 'TEXT', ( !bError and bSuccess ) ? 'SUCCESS' : 'FAILURE' ))
                      else
                        results.add_result( Maadi::Procedure::Result.new( step, '', 'TEXT', 'UNKNOWN' ))
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