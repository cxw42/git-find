use lib::relative '.';
use TestKit;
use App::GitFind::cmdline;
our $r = \&App::GitFind::cmdline::_is_valid_ref;

BEGIN { make_assertion 'bad', 'ok !$main::r->($_[0]), $_[1]'; }
bad '';
die $@ if $@;    # In case of errors in bad() detected only at runtime

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
