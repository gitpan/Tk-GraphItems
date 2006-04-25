use 5.008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Tk::GraphItems',
    VERSION_FROM      => 'lib/Tk/GraphItems.pod', # finds $VERSION
    PREREQ_PM         => {Tk=> 8.4}, # e.g., Module::Name => 1.1
    #($] >= 5.005 ?     ## Add these new keywords supported since 5.005
    ABSTRACT_FROM  => 'lib/Tk/GraphItems.pod', # retrieve abstract from module
    AUTHOR         => 'Ch.Lamprecht <ch.l.ngre@online.de>',
	     );
