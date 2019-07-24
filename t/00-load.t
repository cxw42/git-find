#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'App::GitFind' ) || print "Bail out!\n";
}

diag( "Testing App::GitFind $App::GitFind::VERSION, Perl $], $^X" );
