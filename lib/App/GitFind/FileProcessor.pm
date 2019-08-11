package App::GitFind::FileProcessor;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.000001';

use parent 'App::GitFind::Class';
use Class::Tiny qw(expr searchbase);

# Imports
use App::GitFind::Base;
use App::GitFind::Actions qw(argdetails);
use App::GitFind::FileStatLs ();
use File::Spec;
use Getargs::Mixed;
use Git::Raw;

# === Documentation === {{{1

=head1 NAME

App::GitFind::FileProcessor - Test a file against a set of criteria

=head1 SYNOPSIS

    my $hrArgs = App::GitFind::cmdline::Parse(\@ARGV);
    my $runner = App::GitFind::FileProcessor->new(-expr => $hrArgs->{expr});
    $runner->process($some_entry_or_other);

=cut

# }}}1
# === Main interpreter === {{{1

=head2 process

Process a single file, represented as an L<App::GitFind::Entry> instance.
Returns the Boolean result of the expression.  Note that the specific
exit codes from C<-exec> and similar actions are lost.  Usage:

    $runner->process([-entry=>]$entry);

=cut

sub process {
    my ($self, %args) = parameters('self',[qw(entry)], @_);
    @_ = ($self, $args{entry}, $self->expr);
    goto &_process;
} #process()

# Internal: $self->_process($entry, $expr)
sub _process {
    my ($self, $entry, $expr) = @_;
    my $func;   # What will handle the expression
    my @arg;    # Args to $func

    vlog { Processing => ddc($expr) } 3;

    die "Invalid expression: " . ddc($expr) unless ref $expr eq 'HASH';

    if($expr->{name}) {                 # Basic elements
        $func = $self->can('do_' . $expr->{name});
            # TODO remove the can() check once everything is implemented
        @arg = $entry;
        push @arg, @{$expr->{params}} if $expr->{params};

    } else {                      # SEQ, AND, OR, NOT
        die "Logical expression has more than one key: " . ddc($expr)
            if scalar keys %{$expr} > 1;
        my $operation = (keys %{$expr})[0];
        $func = $self->can("process_$operation");
            # TODO remove the can() check once everything is implemented
        @arg = ($entry, $expr->{$operation});

    }

    die "I don't know how to process the expression: " . ddc($expr)
        unless $func;

    return $self->$func(@arg);
} #_process()

# }}}1
# === Helpers === {{{1

=head2 dot_relative_path

Given a path, adds C<./> or C<.\> unless it is an absolute path.  This is
a hacked workaround for the issue noted in
L<https://bitbucket.org/shlomif/perl-file-find-object/issues/3/not-consistently-present-in-returned-paths>.

=cut

# Make a regex that will match ./ or .\ in a platform-independent way
my $_dotslash = File::Spec->catfile('.','');    # platform-independent ./
my $_ddotslash = File::Spec->catfile('..','');    # platform-independent ./
$_dotslash = qr{^(?:\Q$_dotslash\E|\Q$_ddotslash\E)};

sub dot_relative_path {
    my $path = $_[1]->path;     # $_[1] is an Entry
    return $path if File::Spec->file_name_is_absolute($path);
    return $path if $path =~ $_dotslash || $path eq '.';
    return File::Spec->catfile('.',$path);
} #dot_relative_path()

# }}}1
# === Logical operators === {{{1

=head2 process_NOT

Process a negation of a single expression.  Usage:

    $runner->process_NOT($entry, $expr);

Even though the name of the parameter is C<exprs> for consistency with
AND, OR, and SEQ, only a single expression is allowed.

=cut

sub process_NOT {
    my ($self, $entry, $expr) = @_;
    croak "I can't take an array of expressions"
        if ref $expr eq 'ARRAY';

    return !$self->_process($entry, $expr);
} #process_NOT()

=head2 process_AND

Process a conjunction of expressions.  Usage:

    $runner->process_AND($entry, [$expr1, ...]);

=cut

sub process_AND {
    my ($self, $entry, $lrExprs) = @_;
    my $retval;

    for(@$lrExprs) {
        $retval = $self->_process($entry, $_);
        last unless $retval;    # Short-circuit
    }
    return $retval;
} #process_AND()

=head2 process_OR

Process a disjunction of expressions.  Usage:

    $runner->process_OR($entry, [$expr1, ...]);

=cut

sub process_OR {
    my ($self, $entry, $lrExprs) = @_;
    my $retval;

    for(@$lrExprs) {
        $retval = $self->_process($entry, $_);
        last if $retval;    # Short-circuit
    }
    return $retval;
} #process_OR()

=head2 process_SEQ

Process a sequence of expressions.  Usage:

    $runner->process_SEQ($entry, [$expr1, ...]);

=cut

sub process_SEQ {
    my ($self, $entry, $lrExprs) = @_;
    my $retval;

    $retval = $self->_process($entry, $_) foreach @{$lrExprs};
    return $retval;
} #process_SEQ()

# }}}1
# === Tests/actions === {{{1
# The order matches that in App::GitFind::Actions

# No-argument tests {{{2

# empty
# executable

sub do_false { false }

# nogroup
# nouser
# readable

sub do_true { true }

# writeable

# }}}2
# No-argument actions {{{2

# delete

sub do_ls { print App::GitFind::FileStatLs::ls_stat($_[1]->path); true } # $_[0]=self
    # TODO optimization?  Pull the stat() results from $_[1] rather than
    # re-statting.  May not be an issue.

sub do_print { say $_[0]->dot_relative_path($_[1]); true }  # $_[0] = self

sub do_print0 { print $_[0]->dot_relative_path($_[1]), "\0"; true }

# prune

# quit
# This appears to be a GNU extension.  It should:
#   - Finish any child processes
#       (empirical): do not kill -9 ---
#       find . -name LICENSE -exec sh -c 'sleep 2' {} + -o -name README -quit
#       does not terminate the `sleep` early.
#   - Run any queued -execdir {} + commands
#   - (empirical) Do not run any queued -exec {} + commands?
#       E.g., GNU
#           find . \( -name LICENSE -quit -o -name README \) -exec ls -l {} +
#       prints nothing.  However, POSIX
#       (http://pubs.opengroup.org/onlinepubs/9699919799/utilities/find.html)
#       says that "The utility ... shall be invoked ... after the last
#       pathname in the set is aggregated, and shall be completed
#       **before the find utility exits**" (emphasis added).


# }}}2
# One-argument index tests
# TODO

# }}}2
# One-argument detailed tests
# TODO

# }}}2
# -newerXY forms (all are one-argument detailed tests)
# TODO

# }}}2
# -newerXY forms (all are one-argument detailed tests)
# TODO

# }}}2
# Actions with a fixed number of arguments

# fls file
# fprint file
# fprint0 file
# fprintf file format

sub do_printf { # -printf format.  No newline at the end.
    my ($self, %args) = parameters('self',[qw(entry format)], @_);
    print "printf($args{format}, $args{entry})";    # TODO
} #do_printf()

# }}}2
# Actions with a delimited argument list

# exec
# execdir
# ok
# okdir

# }}}2

# }}}1

1; # End of App::GitFind::FileProcessor
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
