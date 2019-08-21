package App::GitFind::Actions;
use warnings;
use strict;
use 5.010;
use constant true => 1;

sub dot_relative_path { }

our $target1 = sub {
    true
};

our $target2 = sub {
    say $_[0]->dot_relative_path($_[1]);
};

package main;

use Carp::Always;
use Data::Dumper::Compact 'ddc';
use v5.10;

my $inner1 = {code=>$App::GitFind::Actions::target1, index => 1, name => 'true'};
my $inner2 = {code=>$App::GitFind::Actions::target2, name => 'print'};

my $expr = {AND=>[$inner1, $inner2]};
my $switches = {v=>[1,1]};

say ddc({expr=>$expr, switches=>$switches});
