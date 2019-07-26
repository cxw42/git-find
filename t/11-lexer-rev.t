use strict;
use warnings;
use Test::More;
use List::AutoNumbered;

use App::GitFind::cmdline;
my $r = \&App::GitFind::cmdline::_is_valid_rev;

sub bad {
    my ($s, $name) = @_;
    my (undef, $filename, $line) = caller;
    $name ||= "line $line";
    # Show errors at the correct line number
    eval "\n#line $line $filename\n" .
    'ok !$r->($s), $name' . "\n";
}

sub good {
    my ($s, $name) = @_;
    my (undef, $filename, $line) = caller;
    $name ||= "line $line";

    # Show errors at the correct line number
    eval "\n#line $line $filename\n" .
    'ok $r->($s), $name' . "\n";
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

#10
bad 'foo\\bar';

# The examples from gitrevisions(7)
my $gitrevisions_good = List::AutoNumbered->new(__LINE__);
$gitrevisions_good->load('dae86e1950b1277e545cee180551750029cfe735')->
    ('dae86e')
    ('v1.7.4.2-679-g3bee7fb')
    ('master')
    ('heads/master')
    ('refs/heads/master')
    ('@')
    ('master@{yesterday}')
    ('HEAD@{5 minutes ago}')
    ('master@{1}')
    ('@{1}')
    ('@{-1}')
    ('master@{upstream}')
    ('@{u}')
    ('master@{push}')
    ('@{push}')
    ('HEAD^')
    ('v1.5.1^0')
    ('HEAD~')
    ('master~3')
    ('v0.99.8^{commit}')
    ('v0.99.8^{}')
    ('HEAD^{/fix nasty bug}')
    (':/fix nasty bug')
    (':/^foo')
    (':/!-foo')
    (':/!!foo')
    ('HEAD:README')
    ('master:./README')
    ('master:foo/../README')    # not in gitrevisions
    (':0:README')
    (':README')
    ('^r1')
    ('r1')
    ('r2')
    ('r1..r2')
    ('r1...r2')
    ('origin..')
    ('origin..HEAD')
    ('..origin')
    ('HEAD..origin')
    ('r1^@')
    ('r1^!')
    ('r1^-')
    ('r1^-1')
    ('r1%1..r2')
    (('aa' x 20) . '^-')
    ('HEAD^2^@')
    ('HEAD^-')
    ('HEAD^-2')
    ('B..C')
    ('B...C')
    ('B^-')
    ('B^..B')
    ('^B^1')
    ('C^@')
    ('C^1')
    ('B^@')
    ('B^1')
    ('B^2')
    ('B^3')
    ('C^!')
    ('^C^@')
    ('^C^!')
;

my $gitrevisions_bad = List::AutoNumbered->new(__LINE__);
$gitrevisions_bad->load(':/!oops')->    #invalid char after !
    #('HEAD^@^2')   # This is a git semantic error - should the parser care?
    ('HEAD^, v1.5.1^0')     # Multiple revs - comma not valid here
    ('HEAD~, master~3')     # ditto
;

foreach(@{$gitrevisions_good->arr}) {
    good $$_[1], "line $$_[0]: -$$_[1]-";
}

foreach(@{$gitrevisions_bad->arr}) {
    bad $$_[1], "line $$_[0]: -$$_[1]-";
}

# Revs
good 'tag-1-g123ae';
good 'tag-g123ae';
good '@';
good 'tag@{3 days ago}';
good 'tag@{2}';
good '@{1}';
good '@{-1}';
good 'tag@{3 days ago}';

done_testing();
