package App::GitFind;

use 5.010;
use strict;
use warnings;

use parent 'App::GitFind::Class';
use Class::Tiny qw(argv _expr _revs _repo _repotop _searchbase
    _scan_submodules);

use App::GitFind::Base;
use App::GitFind::cmdline;
use App::GitFind::Runner;
use Getopt::Long 2.34 ();
use Git::Raw;
use Git::Raw::Submodule;
use IO::Handle;
use Iterator::Simple qw(ichain iflatten igrep imap iter iterator);
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

    my $gf = App::GitFind->new(-argv => \@ARGV, -searchbase => Cwd::getcwd);

May modify the provided array.  May C<exit()>, e.g., on C<--help>.

=cut

sub BUILD {
    my ($self, $hrArgs) = @_;
    croak "Need a -argv arrayref" unless ref $hrArgs->{argv} eq 'ARRAY';
    my $details = _process_options($hrArgs->{argv});
    croak "Need a -searchbase" unless defined $hrArgs->{searchbase};

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

    vlog { "Options:", ddc $details } 2;

    # Copy information into our instance fields
    $self->_expr($details->{expr});
    $self->_revs($details->{revs});
    $self->_searchbase(dir($hrArgs->{searchbase}));

    # Find the repo we're in.  If we're in a submodule, that will be the
    # repo of that submodule.
    $self->_repo( eval { Git::Raw::Repository->discover('.'); } );
    die "Not in a Git repository: $@\n" if $@;

    $self->_repotop( dir($self->_repo->workdir) );  # $repo->path is .git/
    vlog {
        "Repository:", $self->_repo->path,
        "\nWorking dir:", $self->_repotop,
        "\nSearch base:", $self->_searchbase,
    };

    # Are we in a submodule?
    if($self->_repo->path =~ m{\.git[\\\/]modules\b}) {
        vlog { 'In a submodule' };
        # TODO move outward to the parent
    }

    # Should we scan submodules?
    $self->_scan_submodules(true);  # Yes, by default
    $self->_scan_submodules(false)  # No, if ]] is the only ref
        if @{$self->_revs} == 1 && $self->_revs->[0] eq ']]';

} #BUILD()

=head2 run

Does the work.  Call as C<< exit($obj->run()) >>.  Returns a shell exit code.

=cut

sub run {
    my $self = shift;
    my $runner = App::GitFind::Runner->new(-expr => $self->_expr);

    if($VERBOSE) {
        STDOUT->autoflush(true);
        STDERR->autoflush(true);
    }

    my $iter = $self->_entry_iterator($self->_repo);

    while (defined(my $entry = $iter->next)) {
        vlog { $entry->path, '>>>' } 3;
        my $matched = $runner->process($entry);
        vlog { '<<<', $matched ? 'matched' : 'did not match' } 3;
    }

    return 0;   # TODO? return 1 if any -exec failed?
} #run()

=head1 INTERNALS

=head2 _entry_iterator

Create an iterator for the entries to be processed.  Returns an
L<Iterator::Simple>.  Usage:

    my $iter = $self->_entry_iterator($repo);

=cut

sub _entry_iterator {
    my ($self, $repo) = @_;

    # Make iterators for the requested revs with respect to $repo
    my @iters =
        map { $self->_iterator_for(-rev => $_, -in => $repo) }
            List::SomeUtils::uniq @{$self->_revs};

    if($self->_scan_submodules) {
        # Does $repo have submodules? (EXPERIMENTAL)
        my @submodule_names;
        Git::Raw::Submodule->foreach($repo, sub { push @submodule_names, $_[0]; });
        vlog { "Submodules:", join ', ', @submodule_names } if @submodule_names;

        # Make iterators for the submodules.  Don't start on a submodule
        # until we've finished with the top level.
        if(@submodule_names) {
            my $name_iter = iter([@submodule_names]);

            my $subrepo_iter =
                imap {
                    vlog { "Entering submodule", $_ } 2;
                    my $smrepo = Git::Raw::Submodule->lookup($repo, $_);
                    unless($smrepo) {
                        vwarn { "Could not load submodule $_" };
                        return undef;
                    }
                    return $self->_entry_iterator($smrepo->open)
                }
                $name_iter;

            my $submodule_iter = igrep { !!$_ } $subrepo_iter;

            push @iters, $submodule_iter;
        }
    }

    return iflatten ichain @iters;
} #_entry_iterator

=head2 _iterator_for

Return an iterator for a particular rev in a particular repository.  Usage:

    my $iterator = $self->_iterator_for('rev', -in => $repo);

=cut

sub _iterator_for {
    my ($self, %args) = getparameters('self', [qw(rev in)], @_);
    my $rev = $args{rev};
    my $repo = $args{in};

    # TODO find files in scope $self->_revs, repo $repo

    if(!defined $rev) {     # The index of the current repo
        require App::GitFind::Entry::GitIndex;
        my $index = $repo->index;
        return imap {
            App::GitFind::Entry::GitIndex->new(-obj=>$_, -repo=>$repo,
                -searchbase=>$self->_searchbase)
        } iter([$index->entries]);

    } elsif($rev eq 'DEBUG') {   # DEBUG
        require App::GitFind::Entry::PathClass;
        return iter([
            App::GitFind::Entry::PathClass->new(-obj=>file('./TEST!!'),
                -searchbase=>$self->_searchbase)
        ]);

    } elsif($rev eq ']]') { # The current working directory
        require File::Find::Object;
        require App::GitFind::Entry::OnDisk;
        my $findbase =
            dir($repo->workdir)->relative($self->_searchbase);
        my $base_iter = File::Find::Object->new(
            {followlink=>true}, $findbase
        );
        return  igrep { $_ }
                imap { App::GitFind::Entry::OnDisk->new(-obj=>$_,
                                            -searchbase=>$self->_searchbase,
                                            -findbase=>$findbase)
                }
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

    $VERBOSE = scalar @{$hrOpts->{switches}->{v} // []};
    $QUIET = scalar @{$hrOpts->{switches}->{q} // []};

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
