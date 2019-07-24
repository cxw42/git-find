package App::GitFind;

use 5.010;
use strict;
use warnings;

use Getopt::Long 2.34 qw(GetOptionsFromArray :config),
    qw(auto_help auto_version),     # handle -?, --help, --version
    qw(passthrough require_order),  # stop at the first unrecognized.  TODO
    qw(no_getopt_compat gnu_compat bundling);   # --foo, -x, no +x

use Git;

our $VERSION = '0.000001';

# === Documentation === {{{1

=head1 NAME

App::GitFind - Find files anywhere in a Git repository

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use App::GitFind;
    exit App::GitFind->new(\@ARGV)->run;

See L<git-find> for more usage information.

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
    bless $self, $package;
} #new()

=head2 run

Does the work.

=cut

sub run {
    my $repo = Git->repository('.');
    use Data::Dumper;
    say "Repo: ", Dumper $repo;
} #new()

=head1 INTERNALS

=head2 _process_options

Process the options and return a hashref.  Any remaining arguments are
stored under key C<_>.

=cut

sub _process_options {
    my $lrArgv = shift // [];
    my %opts;

    # uncoverable branch true
    GetOptionsFromArray($lrArgv, \%opts, qw(h man v))
        or die 'Error while processing global options';
        # At present, this always succeeds, because it is configured to simply
        # stop at the first unrecognized option, and because none of the
        # options have coderefs or validation.
    $opts{_} = $lrArgv if @$lrArgv;

    Getopt::Long::HelpMessage(-exitval => 0, -verbose => 2) if $opts{man};
    Getopt::Long::HelpMessage(-exitval => 0) if $opts{h};
    Getopt::Long::VersionMessage(-exitval => 0) if $opts{v};

    #Getopt::Long::HelpMessage(-exitval => 2) unless @$lrArgv;

    return \%opts;
} #_process_options

1; # End of App::GitFind
__END__

# === Rest of the docs === {{{1

=head1 AUTHOR

Christopher White, C<< <cxw at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2019 Christopher White.

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
