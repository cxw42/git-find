# App::GitFind::Entry::OnDisk - a file or directory on disk
package App::GitFind::Entry::OnDisk;

use 5.010;
use strict;
use warnings;
use App::GitFind::Base;

our $VERSION = '0.000001'; # TRIAL

use parent 'App::GitFind::Entry';

# Fields.  Not all have values.
use Class::Tiny
    'obj',      # A File::Find::Object::Result instance.  Required.
    {
        isdir => sub { $_[0]->obj->is_dir },
        name => sub {   # basename, whether it's a file or directory
            my @x = $_[0]->obj->full_components;
            $x[$#x]
        },

        path => sub { $_[0]->obj->path },

        dev => sub { $_[0]->obj->stat_ret()->[0] },
        ino => sub { $_[0]->obj->stat_ret()->[1] },
        mode => sub { $_[0]->obj->stat_ret()->[2] },
        nlink => sub { $_[0]->obj->stat_ret()->[3] },
        uid => sub { $_[0]->obj->stat_ret()->[4] },
        gid => sub { $_[0]->obj->stat_ret()->[5] },
        rdev => sub { $_[0]->obj->stat_ret()->[6] },
        size => sub { $_[0]->obj->stat_ret()->[7] },
        atime => sub { $_[0]->obj->stat_ret()->[8] },
        mtime => sub { $_[0]->obj->stat_ret()->[9] },
        ctime  => sub { $_[0]->obj->stat_ret()->[10] },
        blksize => sub { $_[0]->obj->stat_ret()->[11] },
        blocks => sub { $_[0]->obj->stat_ret()->[12] },
    };

# Docs {{{1

=head1 NAME

# App::GitFind::Entry::OnDisk - an App::GitFind::Entry representing a file or directory on disk

=head1 SYNOPSIS

This represents a single file or directory being checked against an expression.
This particular concrete class represents a file or directory on disk.
It requires a L<File::Find::Object::Result> instance.  Usage:

    my $obj = File::Find::Object->new(...)->next_obj;
    my $entry = App::GitFind::Entry::OnDisk->new(-obj => $obj);

=head1 METHODS

=cut

# }}}1

=head2 prune

If this entry represents a directory, mark its children as not to be traversed.

If this entry represents a file, no effect.

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
    die "-obj must be a File::Find::Object::Result"
        unless $self->obj->DOES('File::Find::Object::Result');
} #BUILD()

1;