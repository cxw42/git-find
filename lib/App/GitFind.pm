package App::GitFind;

use 5.010;
use strict;
use warnings;

use parent 'App::GitFind::Class';
use Class::Tiny qw(argv _expr _revs _repo _repotop);

use App::GitFind::Base;
use App::GitFind::cmdline;
use App::GitFind::Entry::OnDisk;
use App::GitFind::Entry::Phony;     # DEBUG
use App::GitFind::Runner;
use Getopt::Long 2.34 ();
use Git::Raw;
use Iterator::Simple qw(ichain imap iter iterator);
use List::SomeUtils;    # uniq
use Path::Class;

our $VERSION = '0.000001';  # TRIAL

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

=head2 BUILD

Process the arguments.  Usage:

    my $gf = App::GitFind->new(-argv => \@ARGV);

May modify the provided array.  May C<exit()>, e.g., on C<--help>.

=cut

sub BUILD {
    my ($self, $hrArgs) = @_;
    croak "Need a -argv arrayref" unless ref $hrArgs->{argv} eq 'ARRAY';
    my $details = _process_options($hrArgs->{argv});

    # Handle default -print
    if(!$details->{expr}) {             # Default: -print
        $details->{expr} = { name => 'print' };

    } elsif(!$details->{sawnpa}) {      # With an expr: -print unless an action
                                        # other than -prune was given
        $details->{expr} = +{
            AND => [ $details->{expr}, { name => 'print' } ]
        };
    }

    # Add default for missing revs
    $details->{revs} = [undef] unless $details->{revs};

    print "Options: ", ddc $details if $TRACE>1;

    # Copy information into our instance fields
    $self->_expr($details->{expr});
    $self->_revs($details->{revs});

    # find the repo we're in
    $self->_repo( eval { Git::Raw::Repository->discover('.'); } );
    die "Not in a Git repository: $@\n" if $@;

    $self->_repotop( dir($self->_repo->commondir)->parent );    # .git/.. dir
    say "Repo in ", $self->_repotop if $TRACE;
} #BUILD()

=head2 run

Does the work.  Call as C<< exit($obj->run()) >>.  Returns a shell exit code.

=cut

sub run {
    my $self = shift;
    my $runner = App::GitFind::Runner->new(-expr => $self->_expr);

    my $iter = $self->_entry_iterator;

    while (defined(my $entry = $iter->next)) {
        print $entry->path, ': ' if $TRACE;
        my $matched = $runner->process($entry);
        print $matched ? 'matched' : 'did not match', "\n" if $TRACE >= 3;
    }

    return 0;   # TODO? return 1 if any -exec failed?
} #run()

=head1 INTERNALS

=head2 _entry_iterator

Create an iterator for the entries to be processed.  Returns an
L<Iterator::Simple>.

=cut

sub _entry_iterator {
    my $self = shift;

    return ichain(
        map { $self->_iterator_for($_) }
            List::SomeUtils::uniq @{$self->_revs}
    );

} #_entry_iterator

=head2 _iterator_for

Return an iterator for a particular rev.

=cut

sub _iterator_for {
    my ($self, $rev) = @_;
    # TODO find files in scope $self->_revs, repo $self->_repo

    if(!defined $rev) {     # The index of the current repo
        # DEBUG
        return iter([
            App::GitFind::Entry::Phony->new(-obj=>file('./TEST!!'))
        ]);

    } elsif($rev eq ']]') { # The current working directory
        require File::Find::Object;
        my $base_iter = File::Find::Object->new({followlink=>true},
                                                $self->_repotop->relative);
        return imap { App::GitFind::Entry::OnDisk->new(-obj=>$_) }
                iterator { $base_iter->next_obj };
                # Separate iterator and imap so imap won't be called once
                # next_obj returns undef.

            # Later items:
            # TODO add an option to report absolute paths instead of relative
            # TODO skip .git and .gitignored files unless -u
            # TODO optimization: if possible, add a filter function
            #       (e.g., for a top-level -type filter)

    } else {
        die "I don't yet know how to search through rev $_";
    }

} #_iterator_for

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
