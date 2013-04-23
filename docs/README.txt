The Maadi High Volume Automated Test (HiVAT) Architecture is designed to be a generalized architecture to
support multiple HiVAT techniques.  Various techniques are described here http://kaner.com/?p=278

* Directory Structure *

.\bin
Contains the command line interface to Maadi (maadi-cli.rb).  When the maadi-cli.rb is executed, the
default.maadi profile is loaded and executed.  Any commands executed at the maadi CLI are available
to be stored in a maadi profile.  At the maadi CLI, entering help will cause the internal help to be
displayed.

.\docs
Contains any Maadi documentation (including this file).

.\lib
Contains all of the components of the Maadi Architecture.  .\lib\core includes all of the core components
of the architecture which are not expected to be customized.  .\lib\custom is the location of all of the
custom components on the architecture.  Each customizable component has its own sub-directory within the
.\lib\custom directory.  At a minimum there is a factory.rb and Example.rb within each directory.  The
factory.rb file is used by the architecture to instantiate any custom components within the component
directory.  The Example.rb provides a rough template to be used for constructing any custom components.

.\tests
Contains all of the unit tests for the architecture.