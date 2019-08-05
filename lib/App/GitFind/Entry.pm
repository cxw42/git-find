# App::GitFind::Entry - Abstract base class representing a file or directory
package App::GitFind::Entry;

use 5.010;
use strict;
use warnings;
use App::GitFind::Base;

our $VERSION = '0.000001'; # TRIAL

use parent 'App::GitFind::Class';

# Fields.  Not all have values.
use Class::Tiny _qwc <<'EOT';
    isdir   # Truthy if it's a directory; falsy otherwise.
    name    # filename/dirname.
            #   TODO May be a string or a Path::Class instance?
    path    # full path (with respect to the search).
            #   TODO May be a string or a Path::Class instance?
    dev     # device number of filesystem
    ino     # inode number
    mode    # file mode  (type and permissions)
    nlink   # number of (hard) links to the file
    uid     # numeric user ID of file's owner
    gid     # numeric group ID of file's owner
    rdev    # the device identifier (special files only)
    size    # total size of file, in bytes
    atime   # last access time in seconds since the epoch
    mtime   # last modify time in seconds since the epoch
    ctime   # inode change time in seconds since the epoch (*)
    blksize # preferred I/O size in bytes for interacting with the
            #   file (may vary from file to file)
    blocks  # actual number of system-specific blocks allocated
EOT

# Docs {{{1

=head1 NAME

App::GitFind::Entry - Abstract base class representing a file or directory

=head1 SYNOPSIS

This represents a single file or directory being checked against an expression.
Concrete subclasses implement various types of entries.

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

Enforce abstractness.

=cut

sub BUILD {
    my $self = shift;
    die "Cannot instantiate abstract base class" if ref $self eq __PACKAGE__;
} #BUILD()

1;
