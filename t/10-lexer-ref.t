use strict;
use warnings;
use Test::More;
use App::GitFind::cmdline;
my $r = \&App::GitFind::cmdline::_is_valid_ref;

sub bad {
    my $s = shift;
    my (undef, $filename, $line) = caller;
    eval <<EOT;     # Show errors at the correct line number
#line $line $filename
    ok !\$r->(\$s), \@_;
EOT
}

# valid refs

ok $r->('a' x 40);
ok $r->('0' x 40);

#1
bad '.';
bad 'foo/.';
bad 'foo.lock/blah';
bad 'foo.lock';

#2 ignored

#3
bad '..';

#4
bad "\003";
bad "\177";
bad '~';
bad 'foo bar';
bad 'foo:bar';

#5
bad '?';
bad '*';
bad '[';
# TODO what about ']'?

#6
bad '/foo';
bad 'bar/';
bad 'foo//bar';

#7
bad 'foo.';

#8
bad 'foo@{bar}';

#9
bad '@';

#10
bad 'foo\\bar';


done_testing();
