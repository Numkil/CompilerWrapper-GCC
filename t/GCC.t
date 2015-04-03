#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 21;
use Test::Differences;
use base qw(Test::Class);

my @subs = qw(findSourceFiles getCommand resetExclusions omitFilesByMatching addGlutFlags addDebugFlags getSourceFiles );

#Can the module find my files
use_ok('CompilerWrapper::GCC', @subs);
can_ok(__PACKAGE__, 'findSourceFiles');
can_ok(__PACKAGE__, 'getSourceFiles');
can_ok(__PACKAGE__, 'getCommand');
can_ok(__PACKAGE__, 'resetExclusions');
can_ok(__PACKAGE__, 'omitFilesByMatching');
can_ok(__PACKAGE__, 'addGlutFlags');
can_ok(__PACKAGE__, 'addDebugFlags');

sub make_fixture : Test(setup) {
    # fill the api
    &findSourceFiles("t/Mockups/");
    # create a list that should be the same as findSourceFiles
    my $correctlist = [
        't/Mockups/fake1.cpp',
        't/Mockups/fake2.cpp',
    ];
    shift->{testarrayfilled} = $correctlist;
}

# Check return value of findSourceFiles
sub test_return_values : Test(4) {
    ok(&findSourceFiles("unexisting.cpp") ==  0, "Expected 0 when looking up a non existing file");
    ok(&findSourceFiles("t/Mockups/fake1.cpp") == 1, "Expected 1 when looking up an existing file");
    ok(&findSourceFiles("unexistingdirectory") == 0, "Expected 0 when looking up a non existing directory");
    ok(&findSourceFiles("t/Mockups/") == 1, "Expected 1 when looking up an existing directory");
}

# Check if getSourceFiles returns  the correctly sorted and filled array
sub getSourceFiles_returns_sorted_array_values : Test {
    my $correctlist = shift->{testarrayfilled};
    my @output = &getSourceFiles();

    eq_or_diff(
        \@output, $correctlist, "getSourceFiles does not return the correct array of sourcefiles after findSourceFiles"
    );
}

# Check if omitFiles removed the correct files
sub omitFilesByMatching_correctly_deletes_filenames : Test {
    &omitFilesByMatching("Mockups");
    my @output = &getSourceFiles();

    eq_or_diff(
        \@output, [], "omitFilesByMatching does not correctly remove the matching filenames"
    );
}

# Check if omitFiles does not remove anything when nothing matches string
sub omitFilesByMatching_correctly_ignores_non_matching_filenames : Test(2) {
    &omitFilesByMatching("foo");
    my @output = &getSourceFiles();
    my $correctlist = shift->{testarrayfilled};

    eq_or_diff(
        \@output, $correctlist, "omitFilesByMatching does not correctly ignore non-matching filenames"
    );

    &omitFilesByMatching("fake1");
    @output = &getSourceFiles();

    eq_or_diff(
        \@output, ["t/Mockups/fake2.cpp"], "omitFilesByMatching does not correctly ignore non-matching filenames"
    );
}

# Check if resetExclusions works
sub resetExclusions_correctly_restores_deleted_filenames : Test {
    # delete the filenames matching Mockups and then try to restore them
    &omitFilesByMatching("Mockups");
    &resetExclusions();
    my $correctlist = shift->{testarrayfilled};
    my @output = &getSourceFiles();

    eq_or_diff(
        \@output, $correctlist, "resetExclusions does not correctly restore removed filenames"
    );
}

# Check getCommand's return value, implicity checks that findsourcefiles adds the files
# and that the layout of command returned is ok
sub getCommand_returns_correct_value_when_filled_and_emptied_andExtraFlags : Test(4) {
    like(
        &getCommand(),
        qr(^g\+\+ -Wall -Wextra -Werror -Wcast-align -Wcast-qual -Wconversion -pedantic -std=c\+\+11 (t/Mockups/fake1\.cpp |t/Mockups/fake2\.cpp ){2}-o a\.out$),
        "getCommand does not return expected output after findSourceFiles"
    );

    &omitFilesByMatching("fake1");
    is(
        &getCommand(), "g++ -Wall -Wextra -Werror -Wcast-align -Wcast-qual -Wconversion -pedantic -std=c++11 t/Mockups/fake2.cpp -o a.out",
        "getCommand does not return expected output after omitFilesByMatching part of the sourcefiles"
    );

    &omitFilesByMatching("fake2");
    is(
        &getCommand(), "g++ -Wall -Wextra -Werror -Wcast-align -Wcast-qual -Wconversion -pedantic -std=c++11 -o a.out",
        "getCommand does not return expected output when list is empty"
    );

    # Checking flags are added correctly
    &addGlutFlags();
    &addDebugFlags();
    like(
        &getCommand(),
        qr(-lglut -lm -lGL -lGLU -ggdb -g3),
        "addGlutFlags or/and addDebugFlags were not properly introduced inside endresult"
    );
}

Test::Class->runtests;
