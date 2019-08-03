package App::GitFind;

use 5.010;
use strict;
use warnings;

use App::GitFind::Base;
use App::GitFind::cmdline;
use App::GitFind::Runner;
use Getopt::Long 2.34 ();
use Git::Raw;

our $VERSION = '0.000001';

# === Documentation === {{{1

=head1 NAME

App::GitFind - Find files anywhere in a Git repository

=head1 SYNOPSIS

This is the implementation of the L<git-find> command (q.v.).  To use it
from Perl code:

    use App::GitFind;
    exit App::GitFind->new(\@ARGV)->run;

=head1 SUBROUTINES/METHODS

=cut

# }}}1

=head2 new

The constructor.  Takes an arrayref of arguments, e.g., C<\@ARGV>.  May
C<exit()>, e.g., on C<--help>.

=cut

sub new {
    my ($package, $lrArgv) = @_;
    my $self = _process_options($lrArgv);

    # Handle default -print
    if(!$self->{expr}) {            # Default: -print
        $self->{expr} = 'print';

    } elsif(!$self->{sawnpa}) {     # With an expr: -print unless an action
                                    # other than -prune was given
        $self->{expr} = +{
            AND => [ $self->{expr}, 'print' ]
        };
    }

    # Add default for missing revs
    $self->{revs} = [undef] unless $self->{revs};

    $self->{repo} = Git::Raw::Repository->open('.');
    print "Repo: ", ddc $self->{repo} if $TRACE;

    bless $self, $package;
} #new()

=head2 run

Does the work.  Call as C<< exit($obj->run()) >>.  Returns a shell exit code.

=cut

sub run {
    my $self = shift;
    my $runner = App::GitFind::Runner->new(-expr => $self->{expr});

    my @entries;
    # TODO find files in -scope => $self->{revs}, -repo => $self->{repo}
    push @entries, './TEST!';      # DEBUG

    for(@entries) {
        print "$_: " if $TRACE;
        my $ok = $runner->process($_);
        print $ok ? 'passed' : 'failed', "\n" if $TRACE;
    }

    return 0;   # TODO return 1 if anything failed.
} #run()

=head1 INTERNALS

=head2 _process_options

Process the options and return a hashref.  Any remaining arguments are
stored under key C<_>.

=cut

sub _process_options {
    my $lrArgv = shift // [];
    my $hrOpts;
    local *have = sub { $hrOpts->{switches}->{$_[0] // $_} };

    $hrOpts = App::GitFind::cmdline::Parse($lrArgv)
        or die 'Could not parse options successfully';

    $TRACE = scalar @{$hrOpts->{switches}->{v} // []};

    Getopt::Long::HelpMessage(-exitval => 0, -verbose => 2) if have('man');
    Getopt::Long::HelpMessage(-exitval => 0, -verbose => 1)
        if have('h') || have('help');
    Getopt::Long::HelpMessage(-exitval => 0) if have('?') || have('usage');
    Getopt::Long::VersionMessage(-exitval => 0) if have('V')||have('version');

    return $hrOpts;
} #_process_options

1; # End of App::GitFind
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
