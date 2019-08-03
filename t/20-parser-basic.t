use strict;
use warnings;
use lib::relative '.';
use TestKit;

#use Data::Dumper;

use App::GitFind::cmdline;
my $p = \&App::GitFind::cmdline::Parse;

my $ok=List::AutoNumbered->new(__LINE__);
$ok->load([qw(-u)], {switches=>{u=>[true]},sawnpa=>false})->    # switch
    ([qw(master)], {revs=>['master'],sawnpa=>false})          # ref
    ([qw(-empty)], {expr=>'empty',sawnpa=>false})             # test
    ([qw(-print)], {expr=>'print',sawnpa=>true})             # action
    ([qw(-u master)], {switches=>{u=>[true]}, revs=>['master'],sawnpa=>false})   # switch + ref
    # switch + ref + test
    (LSKIP 1, [qw(-u master -empty)], {switches=>{u=>[true]}, revs=>['master'], expr=>'empty',sawnpa=>false})
    # switch + ref + action
    (LSKIP 1, [qw(-u master -print)], {switches=>{u=>[true]}, revs=>['master'], expr=>'print',sawnpa=>true})
    # switch + ref + test + action
    (LSKIP 1, [qw(-u master -empty -print)], {switches=>{u=>[true]}, revs=>['master'], expr=>{AND=>['empty', 'print']},sawnpa=>true})
    # Then the same, but with --
    (LSKIP 1, [qw(-u --)], {switches=>{u=>[true]},sawnpa=>false})   # switch
    ([qw(master --)], {revs=>['master'],sawnpa=>false})           # ref
    ([qw(-- -empty)], {expr=>'empty',sawnpa=>false})              # test
    ([qw(-- -print)], {expr=>'print',sawnpa=>true})              # action
    # switch + ref
    (LSKIP 1, [qw(-u master --)], {switches=>{u=>[true]}, revs=>['master'],sawnpa=>false})
    # switch + ref + test
    (LSKIP 1, [qw(-u master -- -empty)], {switches=>{u=>[true]}, revs=>['master'], expr=>'empty',sawnpa=>false})
    # switch + ref + action
    (LSKIP 1, [qw(-u master -- -print)], {switches=>{u=>[true]}, revs=>['master'], expr=>'print',sawnpa=>true})
    # switch + ref + test + action
    (LSKIP 1, [qw(-u master -- -empty -print)], {switches=>{u=>[true]}, revs=>['master'], expr=>{AND=>['empty', 'print']},sawnpa=>true})
;

# More complicated tests
$ok->load(LSKIP 3, [qw(-empty -o -readable -true)], {expr=>{OR=>['empty', {AND=>['readable','true']}]},sawnpa=>false})->
    (['-executable', ',', '-readable'], {expr=>{SEQ=>[qw(executable readable)]},sawnpa=>false})
    (['-executable', ',', '-readable', '-empty'], {expr=>{SEQ=>['executable',{AND=>[qw(readable empty)]}]},sawnpa=>false})
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
