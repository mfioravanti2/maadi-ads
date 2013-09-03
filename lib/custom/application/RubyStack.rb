
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
                  lValue = -1
                  rValue = -1
                  bSuccess = false
                  bError = false

                  begin
                    case step.id
                      when 'PUSH'
                        rValue = step.get_parameter_value('[RVALUE]')
                        if rValue != ''
                          bSuccess = true
                          bError = false
                        end
                      when 'POP'
                        lValue = @rStack.pop
                        if rValue != ''
                          bSuccess = true
                          bError = false
                        end
                      when 'SIZE'
                        lValue = @rStack.count

                      when 'ATINDEX'

                      when 'NULCONSTRUCT'
                        @rStack = new.Array()

                        if rValue != ''
                          bSuccess = true
                          bError = false
                        end
                      when 'NONNULCONSTRUCT'
                        @rStack = new.Array()

                        if rValue != ''
                          bSuccess = true
                          bError = false
                        end
                      else
                    end

                    case step.look_for
                      when 'NORECORD'
                      when 'CHANGES'
                        results.add_result( Maadi::Procedure::Result.new( step, '', 'TEXT', 'SUCCESS' ))
                      when 'COMPLETED'
                        results.add_result( Maadi::Procedure::Result.new( step, '', 'TEXT', 'SUCCESS' ))
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