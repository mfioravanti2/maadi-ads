# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : update.rb
#
# Summary: CLI command to automatically assign objects which do not require user interaction

require_relative 'globals'
require_relative '../manager/manager'

module Maadi
  module CLI
    def self.refresh_items( type )
      # setup for global variable maintenance
      if ( type.downcase == 'expert' ) || ( type.downcase == 'organizer' )
        if ( $expert != nil ) && ( $organizer != nil )
          $generator = Maadi::Generator::Generator.new( $expert, $organizer )
        end
      end

      if $controller == nil
        if ( $scheduler != nil ) && ( $generator != nil ) && ( $applications.length > 0 ) && ( $collectors.length > 0 ) && ( $monitors != nil )
          $controller = Maadi::Controller::Controller.new( $scheduler, $generator, $applications, $collectors, $monitors, $runs )

          # if the Controller was remove, then the Manager will need to be re-initialized.
          $manager = nil
        end
      end

      if $manager == nil
        if ( $collectors.length > 0 ) && ( $controller != nil ) && ( $analyzers.length > 0 != nil )
          $manager = Maadi::Manager::Manager.new( $collectors, $controller, $analyzers )
        end
      end
    end
  end
end
