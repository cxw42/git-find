#!/usr/bin/env perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::UseAllModules;

BEGIN { all_uses_ok; }

diag( "Testing App::GitFind $App::GitFind::VERSION, Perl $], $^X" );

done_testing;
