# App::GitFind::Entry::Phony - a file or directory that does not exist
package App::GitFind::Entry::Phony;

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
        '_stat' => sub { [lstat($_[0]->obj->path)] },

        isdir => sub { $_[0]->obj->is_dir },
        name => sub { $_[0]->obj->basename },
        path => sub { '' . $_[0]->obj },

        dev => sub { 1 },   # Fake stat entries
        ino => sub { 1 },
        mode => sub { 0644 },
        nlink => sub { 1 },
        uid => sub { 1 },
        gid => sub { 1 },
        rdev => sub { 0 },
        size => sub { 0 },
        atime => sub { 1 },
        mtime => sub { 1 },
        ctime  => sub { 1 },
        blksize => sub { 1 },
        blocks => sub { 1 },
    };

# Docs {{{1

=head1 NAME

# App::GitFind::Entry::Phony - an App::GitFind::Entry representing a file or directory on disk

=head1 SYNOPSIS

This represents a single file or directory being checked against an expression.
This particular concrete class represents a file or directory on disk.
It requires a L<File::Find::Object::Result> instance.  Usage:

    my $obj = File::Find::Object->new(...)->next_obj;
    my $entry = App::GitFind::Entry::Phony->new(-obj => $obj);

=head1 METHODS

=cut

# }}}1

=head2 prune

A no-op (this is a fake entry, after all!).

=cut

sub prune { }

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
