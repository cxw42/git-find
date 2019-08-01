package App::GitFind::Runner;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.000001';

use App::GitFind::Class qw(expr);

use constant true => !!1;
use constant false => !!0;

# Imports
use App::GitFind::Actions qw(argdetails);
use Carp qw(croak);
use Data::Dumper;   # Actually used in error messages
use Getargs::Mixed;
use Git::Raw;

# === Documentation === {{{1

=head1 NAME

App::GitFind::Runner - Test a file against a set of criteria

=head1 SYNOPSIS

    my $hrArgs = App::GitFind::cmdline::Parse(\@ARGV);
    my $runner = App::GitFind::Runner->new(-expr => $hrArgs->{expr});
    $runner->process($some_entry_or_other);

=cut

# }}}1
# === Main interpreter === {{{1

=head2 process

Process a single file, represented as an L<App::GitFind::Entry> instance.
Returns the Boolean result of the expression.  Note that the specific
exit codes from C<-exec> and similar actions are lost.  Usage:

    $runner->process($entry);

=cut

sub process {
    my ($self, %args) = parameters('self',[qw(expr)], @_);
    my $expr = $args{expr};
    my $func;   # What will handle the expression
    my @arg;    # Args to $func

    if(ref $expr eq 'HASH') {     # SEQ, AND, OR, NOT
        die "Expression has more than one key!  " . Dumper($expr)
            if scalar keys %{$expr} > 1;
        my $operation = (keys %{$expr})[0];
        my $func = $self->can("process_$operation");
        @arg = $expr->{$operation};

    } else {                            # Basic elements
        my $func = $self->can("do_$expr");
        my @arg = $expr;    # in case I later want to alias functions
    }

    die "I don't know how to process the expression: " . Dumper($expr)
        unless $func;

    return $self->$func(@arg);
} #process()

# }}}1
# === Logical operators === {{{1

=head2 process_NOT

Process a negation of a single expression.  Usage:

    $runner->process_NOT([-exprs=>]$expr);

Even though the name of the parameter is C<exprs> for consistency with
AND, OR, and SEQ, only a single expression is allowed.

=cut

sub process_NOT {
    my ($self, %args) = parameters('self',[qw(exprs)], @_);
    croak "I can't take an array of expressions"
        if ref $args{exprs} eq 'ARRAY';

    return !$self->process($args{exprs});
} #process_NOT()

=head2 process_AND

Process a conjunction of expressions.  Usage:

    $runner->process_AND([-exprs=>][$expr1, ...]);

=cut

sub process_AND {
    my ($self, %args) = parameters('self',[qw(exprs)], @_);
    my $retval;

    for(@{$args{exprs}}) {
        $retval = $self->process($_);
        last unless $retval;    # Short-circuit
    }
    return $retval;
} #process_AND()

=head2 process_OR

Process a disjunction of expressions.  Usage:

    $runner->process_OR([-exprs=>][$expr1, ...]);

=cut

sub process_OR {
    my ($self, %args) = parameters('self',[qw(exprs)], @_);
    my $retval;

    for(@{$args{exprs}}) {
        $retval = $self->process($_);
        last if $retval;    # Short-circuit
    }
    return $retval;
} #process_OR()

=head2 process_SEQ

Process a sequence of expressions.  Usage:

    $runner->process_SEQ([-exprs=>][$expr1, ...]);

=cut

sub process_SEQ {
    my ($self, %args) = parameters('self',[qw(exprs)], @_);
    my $retval;

    $retval = $self->process($_) foreach @{$args{exprs}};
    return $retval;
} #process_SEQ()

# }}}1
# === Class/instance routines === {{{1


# }}}1

1; # End of App::GitFind::Runner
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
