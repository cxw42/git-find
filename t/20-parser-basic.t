use strict;
use warnings;
use lib::relative '.';
use TestKit;

#use Data::Dumper;

use App::GitFind::cmdline;
my $p = \&App::GitFind::cmdline::Parse;

my $ok=List::AutoNumbered->new(__LINE__);
$ok->load([qw(-u)], {switches=>{u=>[true]},saw_nonprune_action=>false})->    # switch
    ([qw(master)], {revs=>['master'],saw_nonprune_action=>false})          # ref
    ([qw(-empty)], {expr=>{name=>'empty'},saw_nonprune_action=>false})             # test
    ([qw(-print)], {expr=>{name=>'print'},saw_nonprune_action=>true})             # action
    ([qw(-u master)], {switches=>{u=>[true]}, revs=>['master'],saw_nonprune_action=>false})   # switch + ref
    # switch + ref + test
    (LSKIP 1, [qw(-u master -empty)], {switches=>{u=>[true]}, revs=>['master'], expr=>{name=>'empty'},saw_nonprune_action=>false})
    # switch + ref + action
    (LSKIP 1, [qw(-u master -print)], {switches=>{u=>[true]}, revs=>['master'], expr=>{name=>'print'},saw_nonprune_action=>true})
    # switch + ref + test + action
    (LSKIP 1, [qw(-u master -empty -print)], {switches=>{u=>[true]}, revs=>['master'], expr=>{AND=>[{name=>'empty'}, {name=>'print'}]},saw_nonprune_action=>true})
    # Then the same, but with --
    (LSKIP 1, [qw(-u --)], {switches=>{u=>[true]},saw_nonprune_action=>false})   # switch
    ([qw(master --)], {revs=>['master'],saw_nonprune_action=>false})           # ref
    ([qw(-- -empty)], {expr=>{name=>'empty'},saw_nonprune_action=>false})              # test
    ([qw(-- -print)], {expr=>{name=>'print'},saw_nonprune_action=>true})              # action
    # switch + ref
    (LSKIP 1, [qw(-u master --)], {switches=>{u=>[true]}, revs=>['master'],saw_nonprune_action=>false})
    # switch + ref + test
    (LSKIP 1, [qw(-u master -- -empty)], {switches=>{u=>[true]}, revs=>['master'], expr=>{name=>'empty'},saw_nonprune_action=>false})
    # switch + ref + action
    (LSKIP 1, [qw(-u master -- -print)], {switches=>{u=>[true]}, revs=>['master'], expr=>{name=>'print'},saw_nonprune_action=>true})
    # switch + ref + test + action
    (LSKIP 1, [qw(-u master -- -empty -print)], {switches=>{u=>[true]}, revs=>['master'], expr=>{AND=>[{name=>'empty'}, {name=>'print'}]},saw_nonprune_action=>true})
;

# More complicated tests
$ok->load(LSKIP 3, [qw(-empty -o -readable -true)], {expr=>{OR=>[{name=>'empty'}, {AND=>[{name=>'readable'},{name=>'true'}]}]},saw_nonprune_action=>false})->
    (['-executable', ',', '-readable'], {expr=>{SEQ=>[{name=>'executable'}, {name=>'readable'}]},saw_nonprune_action=>false})
    (['-executable', ',', '-readable', '-empty'], {expr=>{SEQ=>[{name=>'executable'},{AND=>[{name=>'readable'},{name=>'empty'}]}]},saw_nonprune_action=>false})
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
