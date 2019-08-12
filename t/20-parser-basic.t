use strict;
use warnings;
use lib::relative '.';
use TestKit;

#use Data::Dumper;

use App::GitFind::cmdline;
my $p = \&App::GitFind::cmdline::Parse;

my $ok=List::AutoNumbered->new(__LINE__);
$ok->load([qw(-u)], {switches=>{u=>[true]},saw_nonprune_action=>false, saw_non_rr=>false, saw_rr=>false})->    # switch
    ([qw(master)], {revs=>['master'],saw_nonprune_action=>false, saw_non_rr=>true, saw_rr=>false})          # ref
    ([qw(-empty)], {expr=>{name=>'empty'},saw_nonprune_action=>false, saw_non_rr=>false, saw_rr=>false})             # test
    ([qw(-print)], {expr=>{name=>'print'},saw_nonprune_action=>true, saw_non_rr=>false, saw_rr=>false})             # action
    ([qw(-u master)], {switches=>{u=>[true]}, revs=>['master'],saw_nonprune_action=>false, saw_non_rr=>true, saw_rr=>false})   # switch + ref
    # switch + ref + test
    (LSKIP 1, [qw(-u master -empty)], {switches=>{u=>[true]}, revs=>['master'], expr=>{name=>'empty'},saw_nonprune_action=>false, saw_non_rr=>true, saw_rr=>false})
    # switch + ref + action
    (LSKIP 1, [qw(-u master -print)], {switches=>{u=>[true]}, revs=>['master'], expr=>{name=>'print'},saw_nonprune_action=>true, saw_non_rr=>true, saw_rr=>false})
    # switch + ref + test + action
    (LSKIP 1, [qw(-u master -empty -print)], {switches=>{u=>[true]}, revs=>['master'], expr=>{AND=>[{name=>'empty'}, {name=>'print'}]},saw_nonprune_action=>true, saw_non_rr=>true, saw_rr=>false})
    # Then the same, but with --
    (LSKIP 1, [qw(-u --)], {switches=>{u=>[true]},saw_nonprune_action=>false, saw_non_rr=>false, saw_rr=>false})   # switch
    ([qw(master --)], {revs=>['master'],saw_nonprune_action=>false, saw_non_rr=>true, saw_rr=>false})           # ref
    ([qw(-- -empty)], {expr=>{name=>'empty'},saw_nonprune_action=>false, saw_non_rr=>false, saw_rr=>false})              # test
    ([qw(-- -print)], {expr=>{name=>'print'},saw_nonprune_action=>true, saw_non_rr=>false, saw_rr=>false})              # action
    # switch + ref
    (LSKIP 1, [qw(-u master --)], {switches=>{u=>[true]}, revs=>['master'],saw_nonprune_action=>false, saw_non_rr=>true, saw_rr=>false})
    # switch + ref + test
    (LSKIP 1, [qw(-u master -- -empty)], {switches=>{u=>[true]}, revs=>['master'], expr=>{name=>'empty'},saw_nonprune_action=>false, saw_non_rr=>true, saw_rr=>false})
    # switch + ref + action
    (LSKIP 1, [qw(-u master -- -print)], {switches=>{u=>[true]}, revs=>['master'], expr=>{name=>'print'},saw_nonprune_action=>true, saw_non_rr=>true, saw_rr=>false})
    # switch + ref + test + action
    (LSKIP 1, [qw(-u master -- -empty -print)], {switches=>{u=>[true]}, revs=>['master'], expr=>{AND=>[{name=>'empty'}, {name=>'print'}]},saw_nonprune_action=>true, saw_non_rr=>true, saw_rr=>false})
;

# More complicated tests
$ok->load(LSKIP 3, [qw(-empty -o -readable -true)], {expr=>{OR=>[{name=>'empty'}, {AND=>[{name=>'readable'},{name=>'true'}]}]},saw_nonprune_action=>false, saw_non_rr=>false, saw_rr=>false})->
    (['-executable', ',', '-readable'], {expr=>{SEQ=>[{name=>'executable'}, {name=>'readable'}]},saw_nonprune_action=>false, saw_non_rr=>false, saw_rr=>false})
    (['-executable', ',', '-readable', '-empty'], {expr=>{SEQ=>[{name=>'executable'},{AND=>[{name=>'readable'},{name=>'empty'}]}]},saw_nonprune_action=>false, saw_non_rr=>false, saw_rr=>false})
;

foreach(@{$ok->arr}) {
    my $lineno = $$_[0];
    my $lrArgs = $$_[1];
    my $name = "line $$_[0]: [" . join(' : ', @$lrArgs) . ']';
    #diag "======================================\nTrying $name";
    my $ast = $p->($lrArgs);    # add ,0x1f for full debug output
    is_deeply $ast, $$_[2], $name;
    #diag "GOT ", Dumper $ast;
    #diag "WANT ", Dumper $$_[2];
}

done_testing();
