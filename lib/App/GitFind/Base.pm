package App::GitFind::Base;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.000001';

use parent 'Exporter';
use vars::i '$TRACE' => 0;
use vars::i '@EXPORT' => qw(*TRACE true false);

use Import::Into;

use constant true => !!1;
use constant false => !!0;

# Re-exports
use Carp ();
use Data::Dumper::Compact ();

# === Documentation === {{{1

=head1 NAME

App::GitFind::Base - base definitions for App::GitFind

=head1 SYNOPSIS

    use App::GitFind::Base;

Imports L<Carp>, L<Data::Dumper::Compact> (with the C<ddc> option), and
local symbols C<true>, C<false>, and C<$TRACE>.

=head1 VARIABLES

=head2 $TRACE

Set to a positive integer to enable tracing.

=head1 FUNCTIONS

=cut

# }}}1

=head2 import

See L</SYNOPSIS>

=cut

sub import {
    my $target = caller;
    $_[0]->export_to_level(1, @_);
    Carp->import::into($target, qw(carp croak confess cluck));
    Data::Dumper::Compact->import::into($target, 'ddc');
} #import()

1;
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
