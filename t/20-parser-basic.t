use strict;
use warnings;
use lib::relative '.';
use TestKit;

use App::GitFind::cmdline;
my $p = \&App::GitFind::cmdline::Parse;

use Data::Dumper;

my $ok=List::AutoNumbered->new(__LINE__);
$ok->load([qw(-u)], {switches=>{u=>true}})->    # switch
    ([qw(master)], {revs=>['master']})          # ref
    ([qw(-empty)], {expr=>'empty'})             # test
    ([qw(-print)], {expr=>'print'})             # action
    ([qw(-u master)], {switches=>{u=>true}, revs=>['master']})   # switch + ref
    # switch + ref + test
    (LSKIP 1, [qw(-u master -empty)], {switches=>{u=>true}, revs=>['master'], expr=>'empty'})
    # switch + ref + action
    (LSKIP 1, [qw(-u master -print)], {switches=>{u=>true}, revs=>['master'], expr=>'print'})
    # switch + ref + test + action
    (LSKIP 1, [qw(-u master -empty -print)], {switches=>{u=>true}, revs=>['master'], expr=>{AND=>['empty', 'print']}})
    # Then the same, but with --
    (LSKIP 1, [qw(-u --)], {switches=>{u=>true}})   # switch
    ([qw(master --)], {revs=>['master']})           # ref
    ([qw(-- -empty)], {expr=>'empty'})              # test
    ([qw(-- -print)], {expr=>'print'})              # action
    # switch + ref
    (LSKIP 1, [qw(-u master --)], {switches=>{u=>true}, revs=>['master']})
    # switch + ref + test
    (LSKIP 1, [qw(-u master -- -empty)], {switches=>{u=>true}, revs=>['master'], expr=>'empty'})
    # switch + ref + action
    (LSKIP 1, [qw(-u master -- -print)], {switches=>{u=>true}, revs=>['master'], expr=>'print'})
    # switch + ref + test + action
    (LSKIP 1, [qw(-u master -- -empty -print)], {switches=>{u=>true}, revs=>['master'], expr=>{AND=>['empty', 'print']}})
;

# More complicated tests
$ok->load(LSKIP 3, [qw(-empty -o -readable -true)], {expr=>{OR=>['empty', {AND=>['readable','true']}]}})->
    (['-executable', ',', '-readable'], {expr=>{SEQ=>[qw(executable readable)]}})
    (['-executable', ',', '-readable', '-empty'], {expr=>{SEQ=>['executable',{AND=>[qw(readable empty)]}]}})
;

foreach(@{$ok->arr}) {
    my $lineno = $$_[0];
    my $lrArgs = $$_[1];
    my $name = "line $$_[0]: [" . join(' : ', @$lrArgs) . ']';
    #diag "======================================\nTrying $name";
    my $ast = $p->($lrArgs);    # add ,0x1f for full debug output
    #diag Dumper $ast;
    is_deeply $ast, $$_[2], $name;
}

done_testing();
