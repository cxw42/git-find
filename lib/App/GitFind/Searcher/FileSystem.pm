# App::GitFind::Searcher::FileSystem - Search for files on disk
package App::GitFind::Searcher::FileSystem;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.000001'; # TRIAL

use parent 'App::GitFind::Searcher';
use Class::Tiny qw(repo searchbase);

use App::GitFind::Base;
use App::GitFind::Entry::OnDisk;
use File::Find::Object;
use Path::Class;

# Docs {{{1

=head1 NAME

App::GitFind::Searcher::FileSystem - Search for files on disk

=head1 SYNOPSIS

This is an L<App::GitFind::Searcher> that looks through a file system.

=cut

# }}}1

=head1 FUNCTIONS

=head2 run

See L<App::GitFind::Searcher/run>.

=cut

sub run {
    my ($self, $callback) = @_;

    my $findbase =
        dir($self->repo->workdir)->relative($self->searchbase);
    my $base_iter = File::Find::Object->new(
        {followlink=>true}, $findbase
    );

    while(defined(my $ffo = $base_iter->next_obj)) {
        my $entry = App::GitFind::Entry::OnDisk->new(-obj=>$ffo,
                                -searchbase=>$self->searchbase,
                                -findbase=>$findbase);
        $callback->($entry);
        # TODO prune and other control
        undef $entry;
    }
} #run()

=head2 BUILD

=cut

sub BUILD {
    my ($self, $hrArgs) = @_;
    croak 'Need a -searchbase' unless $self->searchbase;
    croak 'Need a -repo' unless $self->repo;
} #BUILD()

1;
__END__
# vi: set fdm=marker: #