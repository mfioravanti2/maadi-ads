
require_relative 'factory'
require_relative '../../core/helpers'

module Maadi
  module Application
    class RubyQueue < Application

      def initialize
        super('RubyQueue')

        @rQueue = nil
      end

      def supported_domains
        return %w(ADS-STACK ALGEBRAICADS-STACK)
      end

      def prepare
        begin
          @rQueue = nil

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
              when 'DETAILS'
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

                if @rQueue != nil
                  Maadi::post_message(:Info, "#{@type}:#{@instance_name} Pre-#{step.id} Stack: ' #{@rQueue.inspect.to_s}",3)
                end

                begin
                  case step.id
                    when 'PUSH'
                      rValue = step.get_parameter_value('[RVALUE]')

                      if @rQueue != nil
                        @rQueue.push rValue
                        lValue = @rQueue.size

                        bSuccess = true
                        bError = false
                      else
                        lValue = rValue = 'PUSH Failed, Queue not instantiated'
                        bSuccess = false
                        bError = true
                      end
                    when 'POP'
                      if @rQueue != nil
                        if @rQueue.size > 0
                          lValue = @rQueue.pop
                          rValue = @rQueue.size

                          bSuccess = true
                          bError = false
                        else
                          lValue = rValue = 'POP Failed, Queue is empty'
                          bSuccess = false
                          bError = true
                        end
                      else
                        lValue = rValue = 'POP Failed, Queue not instantiated'
                        bSuccess = false
                        bError = true
                      end
                    when 'SIZE'
                      if @rQueue != nil
                        lValue = @rQueue.size

                        bSuccess = true
                        bError = false
                      else
                        lValue = rValue = 'SIZE Failed, Queue not instantiated'
                        bSuccess = false
                        bError = true
                      end
                    when 'ATINDEX'
                      index = step.get_parameter_value('[INDEX]')

                      if @rQueue != nil
                        if @rQueue.size > 0
                          if index.to_i < @rQueue.size
                            lValue = @rQueue[index.to_i]
                            rValue = @rQueue.size
                          else
                            lValue = rValue = 'ATINDEX Failed, requested index is larger than queue size'
                            bSuccess = false
                            bError = true
                          end
                        else
                          lValue = rValue = 'ATINDEX Failed, Queue is empty'
                          bSuccess = false
                          bError = true
                        end
                      else
                        lValue = rValue = 'ATINDEX Failed, Queue not instantiated'
                        bSuccess = false
                        bError = true
                      end
                    when 'NULCONSTRUCT'
                      @rQueue = Queue.new()
                      lValue = rValue = @rQueue.size

                      if @rQueue != nil
                        bSuccess = true
                        bError = false
                      end
                    when 'NONNULCONSTRUCT'
                      @rQueue = Queue.new()
                      @rQueue.
                      lValue = rValue = @rQueue.size

                      if @rQueue != nil
                        bSuccess = true
                        bError = false
                      end
                    when 'DETAILS'
                      if @rQueue != nil
                        lValue = @rQueue.to_s
                        bSuccess = true
                        bError = false
                      else
                        #Do nothing
                      end

                    else
                  end

                  #Print some meaningful information
                  if @rQueue != nil
                    Maadi::post_message(:Info, "#{@type}:#{@instance_name} Post-#{step.id} Stack: ' #{@rQueue.inspect.to_s}",3)
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
        @rQueue = nil

        super
      end
    end
  end
end