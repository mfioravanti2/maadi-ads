# Author : Mark Fioravanti (mfioravanti1994@my.fit.edu)
#          Florida Institute of Technology
# Course : CSE5400 Special Topics - High Volume Automated Testing
# Date   : 01/18/2013
# File   : tasker.rb
# License: Creative Commons Attribution
#
# Summary: The tasker will work with the operating system to consume resources
#          on the system.  This will allow disk, memory, or CPU to become restricted
#          as needed.  This should serve as a template class to allow specific
#          operating system implementations to be created.

require_relative '../generic/executable'

module Maadi
  module Tasker
    class Tasker < Maadi::Generic::Executable
      # type (String) is a convenient human readable label.
      def initialize(type)
        super(type)

        @status = Hash.new
        @status[ 'Memory' ] = Hash.new
        @status[ 'Memory' ][ 'Active' ] = false
        @status[ 'Memory' ][ 'Amount' ] = 0

        @status[ 'Disk' ] = Hash.new
        @status[ 'Disk' ][ 'Active' ] = false
        @status[ 'Disk' ][ 'Amount' ] = 0

        @status[ 'CPU' ] = Hash.new
        @status[ 'CPU' ][ 'Active' ] = false
        @status[ 'CPU' ][ 'Amount' ] = 0
      end

      def execution_target
        return 'tasker'
      end

      def self.is_tasker?( tasker )
        if tasker != nil
          if tasker.is_a?( Maadi::Tasker::Tasker )
            return true
          end
        end

        return false
      end

      # use a desired amount of memory on the target system.
      # amount (Integer) amount of memory to consume (in MB)
      # return N/A
      def use_memory( amount )
        if amount > 0
          if @status[ 'Memory' ][ 'Active' ]
            free_memory
          end

          if allocate_memory(amount)
            @status[ 'Memory' ][ 'Amount' ] = amount
            @status[ 'Memory' ][ 'Active' ] = true
          end
        end
      end

      # use a desired amount of memory on the target system.
      # ** This should be the local implementation! **
      # amount (Integer) amount of memory to consume (in MB)
      # return (Bool) true, if the memory was successfully and completely allocated
      def allocate_memory( amount )
        return false
      end

      # determine if memory is being consumed on the target system.
      # return (Bool) true if memory is actively being consumed on the system.
      def using_memory?
        return @status[ 'Memory' ][ 'Active' ]
      end

      # release the memory being consumed on the target system.
      # return N/A
      def free_memory
        if @status[ 'Memory' ][ 'Active' ]
          if deallocate_memory
            @status[ 'Memory' ][ 'Amount' ] = 0
            @status[ 'Memory' ][ 'Active' ] = false
          end
        end
      end

      # release the memory being consumed on the target system.
      # ** This should be the local implementation! **
      # return (Bool) true if the memory was released
      def deallocate_memory
        return false
      end

      # use a desired amount of hard drive space on the target system.
      # amount (Float) amount of disk space to consume (in GB)
      # return N/A
      def use_disk( amount )
        if amount > 0
          if @status[ 'Disk' ][ 'Active' ]
            free_memory
          end

          if allocate_disk( amount )
            @status[ 'Disk' ][ 'Amount' ] = amount
            @status[ 'Disk' ][ 'Active' ] = true
          end
        end
      end

      # use a desired amount of hard drive space on the target system.
      # ** This should be the local implementation! **
      # amount (Float) amount of disk space to consume (in GB)
      # return (Bool) true, if the disk space was successfully and completely allocated
      def allocate_disk( amount )
        return false
      end

      # determine if disk space is being consumed on the target system.
      # return (Bool) true if disk space is actively being consumed on the system.
      def using_disk?
        return @status[ 'Disk' ][ 'Active' ]
      end

      # release the disk space being consumed on the target system.
      # return N/A
      def free_disk
        if @status[ 'Disk' ][ 'Active' ]
          if deallocate_disk
            @status[ 'Disk' ][ 'Amount' ] = 0
            @status[ 'Disk' ][ 'Active' ] = false
          end
        end
      end

      # release the disk space being consumed on the target system.
      # ** This should be the local implementation! **
      # return (Bool) true if the disk space was released
      def deallocate_disk
        return false
      end

      # use a desired percentage of CPU cycles on the target system.
      # amount (Float) amount of CPU cycles to consume (in percentage)
      # return N/A
      def use_cpu( amount )
        if 0.0 < amount && amount < 1.0
          if @status[ 'CPU' ][ 'Active' ]
            free_cpu
          end

          if allocate_cpu( amount )
            @status[ 'CPU' ][ 'Amount' ] = amount
            @status[ 'CPU' ][ 'Active' ] = true
          end
        end
      end

      # use a desired percentage of CPU cycles on the target system.
      # ** This should be the local implementation! **
      # amount (Float) amount of CPU cycles to consume (in percentage)
      # return (Bool) true, if the CPU cycles successfully and completely allocated
      def allocate_cpu( amount )
        return false
      end

      # determine if CPU cycles are being consumed on the target system.
      # return (Bool) true if CPU cycles are actively being consumed on the system.
      def using_cpu?
        return @status[ 'CPU' ][ 'Active' ]
      end

      # release the CPU cycles being consumed on the target system.
      # return N/A
      def free_cpu
        if @status[ 'CPU' ][ 'Active' ]
          if deallocate_cpu
            @status[ 'CPU' ][ 'Amount' ] = 0
            @status[ 'CPU' ][ 'Active' ] = false
          end
        end
      end

      # release the CPU cycles being consumed on the target system.
      # ** This should be the local implementation! **
      # return (Bool) true if the CPU cycles were released
      def deallocate_cpu
        return false
      end

    end
  end
end