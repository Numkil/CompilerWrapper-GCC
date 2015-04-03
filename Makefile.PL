use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'CompilerWrapper::GCC',
    AUTHOR           => q{Numkil <Numkil@hotmail.com>},
    VERSION_FROM     => 'lib/CompilerWrapper/GCC.pm',
    ABSTRACT         => 'An extensive wrapper to the GCC for learning purposes',
    LICENSE          => 'Artistic_2_0',
    MIN_PERL_VERSION => 5.006,
    EXE_FILES        => [
        "script/compilerwrapper"
    ],
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
        'Test::Differences' => 0,
        'Test::Class' => 0,
    },
    PREREQ_PM => {
        'List::MoreUtils' => 0,
        'File::Find::Rule' => 0,
        'Getopt::Long' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'CompilerWrapper-GCC-*' },
);
