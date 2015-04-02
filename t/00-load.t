#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'CompilerWrapper::GCC' ) || print "Bail out!\n";
}

diag( "Testing CompilerWrapper::GCC $CompilerWrapper::GCC::VERSION, Perl $], $^X" );
