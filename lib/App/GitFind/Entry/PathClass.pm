# App::GitFind::Entry::PathClass - App::GitFind::Entry wrapper for a Path::Class instance
package App::GitFind::Entry::PathClass;

use 5.010;
use strict;
use warnings;
use App::GitFind::Base;
use Path::Class;

our $VERSION = '0.000001'; # TRIAL

use parent 'App::GitFind::Entry';

# Fields.  Not all have values.
use Class::Tiny
    'obj',      # A Path::Class instance.  Required.
    {
        # The lstat() results for this entry.  lstat() rather than stat()
        # because searches treat links as individual entries rather than
        # as their referents.  (TODO global option?)
        # This is a lazy initializer so we don't stat() if we don't have to.
        '_stat' => sub { [$_[0]->obj->lstat()] },

        isdir => sub { $_[0]->obj->is_dir },
        name => sub { $_[0]->obj->basename },
        path => sub { '' . $_[0]->obj },

        dev => sub { $_[0]->_stat->[0] },
        ino => sub { $_[0]->_stat->[1] },
        mode => sub { $_[0]->_stat->[2] },
        nlink => sub { $_[0]->_stat->[3] },
        uid => sub { $_[0]->_stat->[4] },
        gid => sub { $_[0]->_stat->[5] },
        rdev => sub { $_[0]->_stat->[6] },
        size => sub { $_[0]->_stat->[7] },
        atime => sub { $_[0]->_stat->[8] },
        mtime => sub { $_[0]->_stat->[9] },
        ctime  => sub { $_[0]->_stat->[10] },
        blksize => sub { $_[0]->_stat->[11] },
        blocks => sub { $_[0]->_stat->[12] },

    };

# Docs {{{1

=head1 NAME

# App::GitFind::Entry::PathClass - App::GitFind::Entry wrapper for a Path::Class instance

=head1 SYNOPSIS

This represents a single file or directory being checked against an expression.
This particular concrete class represents a file or directory on disk.
It requires a L<File::Find::Object::Result> instance.  Usage:

    use Path::Class;
    my $obj = file('foo.txt');      # or dir('bar')
    my $entry = App::GitFind::Entry::PathClass->new(-obj => $obj);

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
    die "Usage: @{[__PACKAGE__]}->new(-obj=>...)"
        unless $self->obj;
    die "-obj must be a Path::Class"
        unless $self->obj->DOES('Path::Class::Entity');
} #BUILD()

1;
