package App::GitFind::Actions;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.000001';

use parent 'Exporter';
use vars::i '@EXPORT_OK' => qw(ARGTEST argdetails);
use vars::i '%EXPORT_TAGS' => { all => [@EXPORT_OK] };

use constant true => !!1;
use constant false => !!0;

# Imports
use Math::Cartesian::Product;

# === Documentation === {{{1

=head1 NAME

App::GitFind::Actions - Worker functions for App::GitFind

=head1 SYNOPSIS

TODO

=head1 FUNCTIONS

=cut

# }}}1
# Definitions of supported command-line arguments {{{1

# Helpers for defining these
sub _a { ($_[0] => { token => 'ACTION', nparam => ($_[1]||0) }) }
sub _t { ($_[0] => { token => 'TEST', nparam => ($_[1]||0), index => ($_[2]||false) }) }

# qw(), but permitting comments.  Call as _qwc(<<EOT).  Thanks to ideas at
# https://www.perlmonks.org/?node=qw%20comments .
sub _qwc ($) {
    my @retval;
    for(split "\n", $_[0]//'') {
        chomp;
        s{#.*$}{};                      # Remove comments
        s{(?:^\s+)|(?:\s+$)}{}g;        # Remove leading/trailing ws
        push @retval, grep { length } split /\s+/;
    }
    return @retval;
} #_qwc()

# A map from argument name to a details hashref.  Valid keys in the hashref are:
#   token:  The token type
#   nparam: - if a regex, the argument ends with an @ARGV element matching
#             that regex.
#           - if an integer, the argument takes that many parameters (>=0).
#   index:  (for tests only) Whether that test can be evaluated using only
#           information from the index

my %ARGS=(
    # TODO find(1) positional options, global options?

    # No-argument tests -- all happen to be index tests
    map( { _t $_, 0, true }
        qw(empty executable false nogroup nouser readable true writeable) ),

    # No-argument actions
    map( { _a $_ } qw(delete ls print print0 prune quit) ),

    # One-argument index tests
    map( { _t $_, 1, true } qw(
        cmin cnewer ctime
        gid group ilname iname inum ipath iregex iwholename level
        mmin mtime name
        path
        regex
        size type uid
        user wholename
    ) ),

    # One-argument detailed tests
    map( { _t $_, 1 } _qwc <<'EOT' ),
        amin anewer atime fstype
        links lname     # Actually index tests?
        newer
        perm            # Actually index test?
        ref rev         # Maybe not detailed tests - TODO investigate this
        samefile        # Actually index test?
        used
EOT

    # -newerXY forms - all are detailed tests
    map( { _t('newer' . join('', @$_), 1) }
        cartesian {1} [qw(a B c m)], [qw(a B c m t)] ),

    # -amin n
    # -anewer file
    # -atime n
    # -cmin n
    # -cnewer file
    # -ctime n
    # -fstype type
    # -gid n
    # -group gname
    # -ilname pattern
    # -iname pattern
    # -inum n
    # -ipath pattern
    # -iregex pattern
    # -iwholename pattern
    # -level n      # not in find(1) - succeed if the item is at level n
    # -links n
    # -lname pattern
    # -mmin n
    # -mtime n
    # -name pattern
    # -newer file
    # -newerXY reference
    # -path pattern
    # -perm [-/+]?mode
    # -ref revspec          # not in find(1) - specify a git ref OR REV
                            # (identical to -rev so you don't have to
                            #  remember which)
    # -regex pattern
    # -rev revspec          # not in find(1) - specify a git rev OR REF
                            # (identical to -ref)
    # -samefile name
    # -size n
    # -type c
    # -uid n
    # -used n
    # -user uname
    # -wholename pattern
    # -xtype c              # Not supported for now
    # -context pattern      # Not supported for now

    # Actions with a fixed number of arguments
    map( { _a $_, 1 } qw(fls fprint fprint0 printf) ),
    map( { _a $_, 2 } qw(fprintf) ),

    # -fls file
    # -fprint file
    # -fprint0 file
    # -fprintf file format
    # -printf format

    # Actions with a delimited argument list
    # -exec command [;+]
    # -execdir command [;+]
    # -ok command ;
    # -okdir command ;
    map( { _a $_, qr/^[;+]$/ } qw(exec execdir) ),
    map( { _a $_, qr/^;$/ } qw(ok okdir) ),
);

# }}}1
# === Argument-validation functions === {{{1
# Special validators for ok, okdir, exec, and execdir.
# Validators return undefined if validation passes, and an error message
# otherwise.  Validators take the command and the located parameters
# in @_.

$ARGS{exec}->{validator} = sub {
    return "need at least a command name" unless $#_>1;
    if($_[$#_] eq '+') {
        return "need a {}" unless grep { $_ eq '{}' } @_;
        return "{} can't be the first argument to $_[0]" if $_[1] eq '{}';
    }
    return undef;
};

$ARGS{execdir}->{validator} = $ARGS{exec}->{validator};

$ARGS{ok}->{validator} = sub {
    return "need at least a command name" unless $#_>1;
    return undef;
};

$ARGS{okdir}->{validator} = $ARGS{ok}->{validator};

# }}}1
# === Accessors for argument information === {{{1

=head2 ARGTEST

Returns a regex that will match any arg, with C<-> or C<--> prefix.  The arg
is captured into $1.  Prototyped as C<()>.

=cut

sub ARGTEST ()
{   # Make a regex that will match any arg, with - or --.
    my $x = join '|', map { quotemeta } keys %ARGS;
    return qr{^--?($x)$};
} #ARGTEST

=head2 argdetails

Returns a hashref of details about the arg, or undef.  Example:

    my $hr = argdetails('true');

=cut

sub argdetails {
    return $ARGS{$_[0]//''};
}

# }}}1

1; # End of App::GitFind::Actions
__END__

# === Rest of the docs === {{{1

=head1 AUTHOR

Christopher White, C<< <cxw at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2019 Christopher White.
Portions copyright 2019 D3 Engineering, LLC.

This program is distributed under the MIT (X11) License:
L<http://www.opensource.org/licenses/mit-license.php>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

=cut

# }}}1
# vi: set fdm=marker fdl=0: #
