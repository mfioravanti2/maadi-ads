# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : test_maadi_spec.rb
#
# Summary: This is the main test driver for the Maadi HiVAT program.

require 'rubygems'
require 'rspec'

require_relative 'core/analyzer/test_analyzer_rspec'
require_relative 'core/application/test_application_rspec'
require_relative 'core/collector/test_collector_rspec'
require_relative 'core/controller/test_controller_rspec'
require_relative 'core/expert/test_expert_rspec'
require_relative 'core/generator/test_generator_rspec'
require_relative 'core/generic/test_generic_rspec'
require_relative 'core/generic/test_executable_rspec'
require_relative 'core/manager/test_manager_rspec'
require_relative 'core/monitor/test_monitor_rspec'
require_relative 'core/procedure/test_procedure_rspec'
require_relative 'core/scheduler/test_scheduler_rspec'
require_relative 'core/tasker/test_tasker_rspec'

require_relative 'custom/analyzer/test_analyzer_rspec'
require_relative 'custom/application/test_application_rspec'
require_relative 'custom/collector/test_collector_rspec'
require_relative 'custom/expert/test_expert_rspec'
require_relative 'custom/monitor/test_monitor_rspec'
require_relative 'custom/organizer/test_organizer_rspec'
require_relative 'custom/procedure/test_procedure_rspec'
require_relative 'custom/scheduler/test_scheduler_rspec'
require_relative 'custom/tasker/test_tasker_rspec'
