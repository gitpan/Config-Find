use 5.006;

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Config::Find',
    'VERSION_FROM'	=> 'lib/Config/Find.pm',
    'PREREQ_PM'		=> {'File::Which' => 0,
			    'File::Spec' => 0,
			    'File::HomeDir' => 0 },
    ($] >= 5.005 ?
      (ABSTRACT_FROM => 'lib/Config/Find.pm',
       AUTHOR     => 'Salvador Fandiño <sfandino@yahoo.com>') : ()),
);
