use strict;
use warnings;
use lib::relative '.';
use TestKit;

use App::GitFind::cmdline;
my $p = \&App::GitFind::cmdline::Parse;

use Data::Dumper;

my $ok=List::AutoNumbered->new(__LINE__);
$ok->load([qw(-u)])->   # switch
    ([qw(master)])      # ref
    ([qw(-empty)])      # test
    ([qw(-print)])      # action
    ([qw(-u master)])   # switch + ref
    ([qw(-u master -empty)])            # switch + ref + test
    ([qw(-u master -print)])            # switch + ref + action
    ([qw(-u master -empty -print)])     # switch + ref + test + action
    # Then the same, but with --
    (LSKIP 1, [qw(-u --)])   # switch
    ([qw(master --)])      # ref
    ([qw(-- -empty)])      # test
    ([qw(-- -print)])      # action
    ([qw(-u master --)])   # switch + ref
    ([qw(-u master -- -empty)])            # switch + ref + test
    ([qw(-u master -- -print)])            # switch + ref + action
    ([qw(-u master -- -empty -print)])     # switch + ref + test + action
;

foreach(@{$ok->arr}) {
    my $lineno = $$_[0];
    my $lrArgs = $$_[1];
    my $name = "line $$_[0]: [" . join(', ', @$lrArgs) . ']';
    diag "======================================\nTrying $name";
    my $ast = $p->($lrArgs);    # add ,0x1f for full debug output
    diag Dumper $ast;
    ok defined($ast), $name;
}

done_testing();
