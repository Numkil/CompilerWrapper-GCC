#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 16;

my @subs = qw(findSourceFiles getCommand resetExclusions omitFilesByMatching addGlutFlags addDebugFlags );
use lib("lib");

#Can the module find my files
use_ok('CompilerWrapper::GCC', @subs);
can_ok(__PACKAGE__, 'findSourceFiles');
can_ok(__PACKAGE__, 'getCommand');
can_ok(__PACKAGE__, 'resetExclusions');
can_ok(__PACKAGE__, 'omitFilesByMatching');
can_ok(__PACKAGE__, 'addGlutFlags');
can_ok(__PACKAGE__, 'addDebugFlags');

#Check return value of findSourceFiles
ok(&findSourceFiles("unexisting.cpp") ==  0, "Expected 0 when looking up a non existing file");
ok(&findSourceFiles("t/Mockups/fake1.cpp") == 1, "Expected 1 when looking up an existing file");
ok(&findSourceFiles("unexistingdirectory") == 0, "Expected 0 when looking up a non existing directory");
ok(&findSourceFiles("t/Mockups/") == 1, "Expected 1 when looking up an existing directory");

#Check getCommand's return value, implicity checks that findsourcefiles adds the files
ok(
    &getCommand() eq "g++ -Wall -Wextra -Werror -Wcast-align -Wcast-qual -Wconversion -pedantic -std=c++11 t/Mockups/fake1.cpp t/Mockups/fake2.cpp -o a.out",
    "getCommand does not return expected output at the default use case"
);

#Check if omitFiles removed the correct files
&omitFilesByMatching("Mockups");
ok(
    &getCommand() eq "g++ -Wall -Wextra -Werror -Wcast-align -Wcast-qual -Wconversion -pedantic -std=c++11 -o a.out",
    "getCommand does not return expected output when omitFilesByMatching has been called"
);
&resetExclusions();
ok(
    &getCommand() eq "g++ -Wall -Wextra -Werror -Wcast-align -Wcast-qual -Wconversion -pedantic -std=c++11 t/Mockups/fake1.cpp t/Mockups/fake2.cpp -o a.out",
    "resetExclusions did not do it's job properly, all the following tests will be wrong"
);
&omitFilesByMatching("fake1");
ok(
    &getCommand() eq "g++ -Wall -Wextra -Werror -Wcast-align -Wcast-qual -Wconversion -pedantic -std=c++11 t/Mockups/fake2.cpp -o a.out",
    "getCommand does not return expected output when omitFilesByMatching has been called, matched too much if the previous test passed"
);
&resetExclusions();

#Checking flags
&addGlutFlags();
&addDebugFlags();
ok(
    &getCommand() eq "g++ -Wall -Wextra -Werror -Wcast-align -Wcast-qual -Wconversion -pedantic -std=c++11 -lglut -lm -lGL -lGLU -ggdb -g3 t/Mockups/fake2.cpp t/Mockups/fake1.cpp -o a.out",
    "addGlutFlags or/and addDebugFlags did not produce the expected output"
);
