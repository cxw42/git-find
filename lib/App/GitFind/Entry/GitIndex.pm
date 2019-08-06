# App::GitFind::Entry::GitIndex - App::GitFind::Entry wrapper for a Git::Raw::Index::Entry
package App::GitFind::Entry::GitIndex;

use 5.010;
use strict;
use warnings;
use App::GitFind::Base;
use Path::Class;

our $VERSION = '0.000001'; # TRIAL

use parent 'App::GitFind::Entry';

# Fields.  Not all have values.
use Class::Tiny
    'obj',      # A Git::Raw::Index::Entry instance.  Required.
    'repo',     # A Git::Raw::Repository instance.  Required.
    {

        # The lstat() results for this entry.  lstat() rather than stat()
        # because searches treat links as individual entries rather than
        # as their referents.  (TODO global option?)
        # This is a lazy initializer so we don't stat() if we don't have to.
        '_stat' => sub { [$_[0]->_pathclass->lstat()] },

        # Lazy cache of a Path::Class instance for this path
        '_pathclass' => sub { file($_[0]->repo->workdir, $_[0]->obj->path) },

        isdir => sub { false },     # Git doesn't store dirs, only files.
        name => sub { $_[0]->_pathclass->basename },
        path => sub { $_[0]->_pathclass },

        # TODO figure out the rest of these
        dev => sub { ...; $_[0]->_stat->[0] },
        ino => sub { ...; $_[0]->_stat->[1] },
        mode => sub { ...; $_[0]->_stat->[2] },
        nlink => sub { ...; $_[0]->_stat->[3] },
        uid => sub { ...; $_[0]->_stat->[4] },
        gid => sub { ...; $_[0]->_stat->[5] },
        rdev => sub { ...; $_[0]->_stat->[6] },
        size => sub { $_[0]->obj->size },
        atime => sub { ...; $_[0]->_stat->[8] },
        mtime => sub { ...; $_[0]->_stat->[9] },
        ctime  => sub { ...; $_[0]->_stat->[10] },
        blksize => sub { ...; $_[0]->_stat->[11] },
        blocks => sub { ...; $_[0]->_stat->[12] },

    };

# Docs {{{1

=head1 NAME

# App::GitFind::Entry::GitIndex - App::GitFind::Entry wrapper for a Git::Raw::Index::Entry

=head1 SYNOPSIS

This represents a single file or directory being checked against an expression.
This particular concrete class represents a Git index entry.
It requires a L<Git::Raw::Index::Entry> instance.  Usage:

    use Git::Raw 0.83;
    my $index = Git::Raw::Repository->discover('.')->index;
    my @entries = $index->entries;
    my $entry = App::GitFind::Entry::GitIndex->new(-obj => $entries[0]);

=head1 METHODS

=cut

# }}}1

=head2 prune

TODO

=cut

sub prune {
    ...
}

=head2 BUILD

Enforces the requirements on the C<-obj> argument to C<new()>.

=cut

sub BUILD {
    my $self = shift;
    die "Usage: @{[__PACKAGE__]}->new(-obj=>..., -repo=>...)"
        unless $self->obj;
    die "-obj must be a Git::Raw::Index::Entry"
        unless $self->obj->DOES('Git::Raw::Index::Entry');
    die "Usage: @{[__PACKAGE__]}->new(-repo=>..., -obj=>...)"
        unless $self->repo;
    die "-obj must be a Git::Raw::Repository"
        unless $self->repo->DOES('Git::Raw::Repository');
} #BUILD()

1;
