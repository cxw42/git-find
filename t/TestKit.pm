# Test kit for App::GitFind
package # hide from PAUSE
    TestKit;

=head1 NAME

TestKit - test kit for App::GitFind

=head1 FUNCTIONS

=cut

# Modules we use and re-export
use 5.010;
use strict;
use warnings;
use Carp qw(croak);
use List::AutoNumbered;
use Test2::V0;

sub true () { !!1 }
sub false () { !!0 }

# Modules we do not re-export
use parent 'Exporter';
use File::Temp;
use Git;

require feature;
use Import::Into;

# === Setup ===

use vars::i '@EXPORT' => qw(make_assertion make_git_repo true false);
use vars::i '%EXPORT_TAGS' => { all => [@EXPORT] };

=head2 import

Re-exports L<Carp>, L<List::Autonumbered>, L<Test2::V0>.
Applies L<strict> and L<warnings> to the caller.

=cut

sub import {
    my $target = caller;
    __PACKAGE__->export_to_level(1, @_);

    feature->import::into($target, ':5.10');
    Carp->import::into($target, qw(carp croak confess cluck));
    $_->import::into($target) foreach qw(strict warnings
        List::AutoNumbered Test2::V0);
}

# === Helpers for use in test files ===

=head2 make_assertion

Make an assertion that test files can use, and that will appear as if
at the line from which it is called.  Usage:

    make_assertion 'name', 'code to run' [, {captures}];

The 'code to run' is a string and can refer to variables C<@_>, C<$caller>,
C<$filename>, and C<$line>.  C<$_[-1]> is always the string "line <#>".

References to outer variables must be given the full package, and C<my>
variables from the caller of C<make_assertion> are not visible since this
is a different lexical scope.

=cut

sub make_assertion {
    my ($target, $called_by_filename, $called_at_line) = caller;
    my ($name, $codestr, $captures) = @_;
    $captures = {} unless $captures;

    # Escape the codestr
    $codestr =~ s/\\/\\\\/g;
    $codestr =~ s/'/\\'/g;

    my $function_body = <<EOT;
    sub {
        use strict;
        use warnings;
        my (undef, \$filename, \$line) = caller;
        push \@_, "line \$line";
        eval "\\n#line \$line \$filename\\n" .
            '$codestr' . "\\n";
    }
EOT

    # Install the function
    no strict 'refs';
    *{"$target\::$name"} = eval($function_body);
} #make_assertion()

=head2 make_git_repo

Make an empty git repository in a temporary directory.  Usage:

    my $repo = make_git_repo;

C<$repo> is a L<Git> instance representing the repository.

The repo is created in a L<File::Temp>-managed directory.  The directory
will be automatically removed when the instance is destroyed.

=cut

sub make_git_repo {
    my $dir = File::Temp->newdir;    # CLEANUP => 1 by default
    Git::command_noisy('init', $dir->dirname);   # dies on error
    my $repo = Git->repository(Directory => $dir->dirname);

    # MAJOR UGLINESS AHEAD
    # The $dir has to outlive the $repo.  Therefore, stuff a
    # reference to $dir into $repo.  This only works because I looked
    # at Git.pm and saw that it uses a blessed hashref as its internal
    # object representation.
    $repo->{"^^ugly_hack_ref_to_dir^^"} = $dir;

    return $repo;
} #make_git_repo()

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
