####################################################################
#
#    This file was generated using Parse::Yapp version 1.21.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package App::GitFind::cmdline;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
use Parse::Yapp::Driver;

#line 9 "support/cmdline.yp"


# Imports {{{1

use 5.010;
use strict;
use warnings;

use App::GitFind::Base;
use App::GitFind::Actions;
use Hash::Merge;

# Debugging support
BEGIN {
    if(
        ($ENV{'APP_GITFIND_CMDLINE_SHOW_AST'} // 0) ||
        ($App::GitFind::cmdline::SHOW_AST // 0)
    ) {
        require XXX;
        XXX->import;
    } else {    # !SHOW_AST - make YYY a passthrough
        no strict 'refs';
        *{'App::GitFind::cmdline::YYY'} = sub {
            return wantarray ? @_ : $_[0];
        };
    }
} #BEGIN

BEGIN { YYY +{ 'YYY loaded' => 1 } }

# }}}1
# Documentation {{{1

=head1 NAME

App::GitFind::cmdline - Command-line parser for git-find

=head1 SYNOPSIS

Generate the .pm file:

    yapp -m App::GitFind::cmdline -o lib/App/GitFind/cmdline.pm support/cmdline.yp

And then:

    use App::GitFind::cmdline;
    App::GitFind::cmdline::Parse(\@ARGV);

For debugging output, set package variable C<$SHOW_AST> to a truthy value
before the C<use> statement:

    BEGIN { $App::GitFind::cmdline::SHOW_AST = 1; }

Or set the C<APP_GITFIND_CMDLINE_SHOW_AST> environment variable to a
truthy value.

=head1 FUNCTIONS

=cut

# }}}1
# Helpers for the parser {{{1

# Merge any number of hashrefs together and return a hashref
sub _merge {
    state $merger = Hash::Merge->new('RETAINMENT_PRECEDENT');
    $merger->set_clone_behavior(false);     # No cloning
    my $retval = {};
    for(@_) {
        next unless ref eq 'HASH';
        $retval = $merger->merge($retval, $_);
    }
    return $retval;
}

# Check for { expr => FOO }
sub _is_single_expr {
    return false unless @_ eq 1;
    my $h = $_[0];
    return false unless ref $h eq 'HASH';
    return false unless keys(%$h) eq 1;
    return false unless (keys %$h)[0] eq 'expr';
    return true;
}

# Make a list describing a switch
sub _switch {
    my ($sw, $val);
    if(ref $_[0] eq 'HASH') {
        $sw = (keys %{$_[0]})[0];
        $val = $_[0]->{$sw};
    } else {
        $sw = $_[0];
        $val = true;
    }
    return ($sw, $val);
} #_switch()

# }}}1



sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.21',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			'LPAREN' => 2,
			'TEST' => 3,
			'REV' => 10,
			'SWITCH' => 11,
			'NOT' => 8,
			'ACTION' => 7
		},
		DEFAULT => -1,
		GOTOS => {
			'cmdline' => 6,
			'switches_and_revs' => 5,
			'expr' => 4,
			'element' => 1,
			'maybeexprplus' => 9
		}
	},
	{#State 1
		DEFAULT => -11
	},
	{#State 2
		ACTIONS => {
			'LPAREN' => 2,
			'TEST' => 3,
			'NOT' => 8,
			'ACTION' => 7
		},
		GOTOS => {
			'expr' => 12,
			'element' => 1
		}
	},
	{#State 3
		DEFAULT => -21
	},
	{#State 4
		ACTIONS => {
			'TEST' => 3,
			'LPAREN' => 15,
			'REV' => 10,
			'SWITCH' => 11,
			'NOT' => 19,
			'ACTION' => 7,
			'COMMA' => 18,
			'OR' => 16,
			'AND' => 17
		},
		DEFAULT => -9,
		GOTOS => {
			'element' => 13,
			'subsequent_expr' => 14,
			'switches_and_revs' => 20
		}
	},
	{#State 5
		ACTIONS => {
			'REV' => 21,
			'SWITCH' => 22,
			'ACTION' => 7,
			'NOT' => 8,
			'TEST' => 3,
			'LPAREN' => 2
		},
		DEFAULT => -8,
		GOTOS => {
			'expr' => 4,
			'element' => 1,
			'maybeexprplus' => 23
		}
	},
	{#State 6
		ACTIONS => {
			'' => 24
		}
	},
	{#State 7
		DEFAULT => -22
	},
	{#State 8
		ACTIONS => {
			'expr4' => 25
		}
	},
	{#State 9
		DEFAULT => -2
	},
	{#State 10
		DEFAULT => -5
	},
	{#State 11
		DEFAULT => -4
	},
	{#State 12
		ACTIONS => {
			'RPAREN' => 26,
			'LPAREN' => 15,
			'TEST' => 3,
			'NOT' => 19,
			'COMMA' => 18,
			'ACTION' => 7,
			'OR' => 16,
			'AND' => 17
		},
		GOTOS => {
			'subsequent_expr' => 14,
			'element' => 13
		}
	},
	{#State 13
		DEFAULT => -18
	},
	{#State 14
		DEFAULT => -14
	},
	{#State 15
		ACTIONS => {
			'ACTION' => 7,
			'NOT' => 8,
			'LPAREN' => 2,
			'TEST' => 3
		},
		GOTOS => {
			'element' => 1,
			'expr' => 27
		}
	},
	{#State 16
		ACTIONS => {
			'NOT' => 8,
			'ACTION' => 7,
			'TEST' => 3,
			'LPAREN' => 2
		},
		GOTOS => {
			'expr' => 28,
			'element' => 1
		}
	},
	{#State 17
		ACTIONS => {
			'LPAREN' => 2,
			'TEST' => 3,
			'NOT' => 8,
			'ACTION' => 7
		},
		GOTOS => {
			'element' => 1,
			'expr' => 29
		}
	},
	{#State 18
		ACTIONS => {
			'ACTION' => 7,
			'NOT' => 8,
			'TEST' => 3,
			'LPAREN' => 2
		},
		GOTOS => {
			'expr' => 30,
			'element' => 1
		}
	},
	{#State 19
		ACTIONS => {
			'expr4' => 31
		}
	},
	{#State 20
		ACTIONS => {
			'SWITCH' => 22,
			'REV' => 21
		},
		DEFAULT => -10
	},
	{#State 21
		DEFAULT => -7
	},
	{#State 22
		DEFAULT => -6
	},
	{#State 23
		DEFAULT => -3
	},
	{#State 24
		DEFAULT => 0
	},
	{#State 25
		DEFAULT => -16
	},
	{#State 26
		DEFAULT => -17
	},
	{#State 27
		ACTIONS => {
			'RPAREN' => 32,
			'LPAREN' => 15,
			'TEST' => 3,
			'AND' => 17,
			'ACTION' => 7,
			'OR' => 16,
			'COMMA' => 18,
			'NOT' => 19
		},
		GOTOS => {
			'element' => 13,
			'subsequent_expr' => 14
		}
	},
	{#State 28
		ACTIONS => {
			'TEST' => 3,
			'LPAREN' => 15,
			'NOT' => 19,
			'AND' => 17,
			'ACTION' => 7
		},
		DEFAULT => -13,
		GOTOS => {
			'subsequent_expr' => 14,
			'element' => 13
		}
	},
	{#State 29
		ACTIONS => {
			'NOT' => 19,
			'ACTION' => 7,
			'TEST' => 3,
			'LPAREN' => 15
		},
		DEFAULT => -15,
		GOTOS => {
			'element' => 13,
			'subsequent_expr' => 14
		}
	},
	{#State 30
		ACTIONS => {
			'ACTION' => 7,
			'AND' => 17,
			'OR' => 16,
			'NOT' => 19,
			'TEST' => 3,
			'LPAREN' => 15
		},
		DEFAULT => -12,
		GOTOS => {
			'subsequent_expr' => 14,
			'element' => 13
		}
	},
	{#State 31
		DEFAULT => -19
	},
	{#State 32
		DEFAULT => -20
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'cmdline', 0,
sub
#line 139 "support/cmdline.yp"
{ YYY +{} }
	],
	[#Rule 2
		 'cmdline', 1,
sub
#line 140 "support/cmdline.yp"
{ YYY $_[1] }
	],
	[#Rule 3
		 'cmdline', 2,
sub
#line 142 "support/cmdline.yp"
{ YYY _merge($_[1], $_[2]) }
	],
	[#Rule 4
		 'switches_and_revs', 1,
sub
#line 147 "support/cmdline.yp"
{
                                        my ($sw, $val) = _switch($_[1]);
                                        YYY +{ switches => {$sw=>[$val]} }
                                    }
	],
	[#Rule 5
		 'switches_and_revs', 1,
sub
#line 155 "support/cmdline.yp"
{ YYY +{ revs => [$_[1]] } }
	],
	[#Rule 6
		 'switches_and_revs', 2,
sub
#line 157 "support/cmdline.yp"
{
                                        my ($sw, $val) = _switch($_[2]);
                                        YYY _merge($_[1],
                                            +{ switches => {$sw=>[$val]} })
                                    }
	],
	[#Rule 7
		 'switches_and_revs', 2,
sub
#line 163 "support/cmdline.yp"
{ YYY _merge($_[1], +{ revs => [$_[2]] }) }
	],
	[#Rule 8
		 'maybeexprplus', 0,
sub
#line 169 "support/cmdline.yp"
{ YYY +{} }
	],
	[#Rule 9
		 'maybeexprplus', 1,
sub
#line 170 "support/cmdline.yp"
{ YYY +{ expr => $_[1] } }
	],
	[#Rule 10
		 'maybeexprplus', 2,
sub
#line 172 "support/cmdline.yp"
{ YYY +{ expr => $_[1], %{$_[2]} } }
	],
	[#Rule 11
		 'expr', 1, undef
	],
	[#Rule 12
		 'expr', 3,
sub
#line 179 "support/cmdline.yp"
{ YYY +{ SEQ => [@_[1,3]] } }
	],
	[#Rule 13
		 'expr', 3,
sub
#line 180 "support/cmdline.yp"
{ YYY +{ OR => [@_[1,3]] } }
	],
	[#Rule 14
		 'expr', 2,
sub
#line 190 "support/cmdline.yp"
{ YYY +{ AND => [@_[1,2]] } }
	],
	[#Rule 15
		 'expr', 3,
sub
#line 191 "support/cmdline.yp"
{ YYY +{ AND => [@_[1,3]] } }
	],
	[#Rule 16
		 'expr', 2,
sub
#line 192 "support/cmdline.yp"
{ YYY +{ NOT => $_[2] } }
	],
	[#Rule 17
		 'expr', 3,
sub
#line 193 "support/cmdline.yp"
{ YYY $_[2] }
	],
	[#Rule 18
		 'subsequent_expr', 1, undef
	],
	[#Rule 19
		 'subsequent_expr', 2,
sub
#line 198 "support/cmdline.yp"
{ YYY +{ NOT => $_[2] } }
	],
	[#Rule 20
		 'subsequent_expr', 3,
sub
#line 199 "support/cmdline.yp"
{ YYY $_[2] }
	],
	[#Rule 21
		 'element', 1, undef
	],
	[#Rule 22
		 'element', 1,
sub
#line 205 "support/cmdline.yp"
{
                $_[0]->YYData->{SAW_NON_PRUNE_ACTION} = true if $_[1] ne 'prune';
                YYY $_[1];
            }
	]
],
                                  @_);
    bless($self,$class);
}

#line 211 "support/cmdline.yp"


#############################################################################
# Footer

# Helpers for the tokenizer {{{1

# Flag a ref as invalid without using regexes.
# Implements https://git-scm.com/docs/git-check-ref-format as archived at
# https://web.archive.org/web/20190725153529/https://git-scm.com/docs/git-check-ref-format

sub _is_ref_ok {
    my $arg = @_ ? $_[0] : $_;

    return false unless defined $arg and length($arg)>0;

    #1 - restrictions on slash-separated components
    if(index($arg, '/') != -1) {
        return false if index($arg, '/.') != -1     #internal components
                    || index($arg, '.lock/') != -1
                    || substr($arg, 0, 1) eq '.'    #components at start/end
                    || substr($arg, -5) eq '.lock';
    }

    # Ignore #2 - assume --allow-onelevel

    #3
    return false if index($arg, '..') != -1;

    #4 - require the caller to check that
    #5 - require the caller to check that - assume NOT --refspec-pattern

    #6 - assume NOT --normalize
    return false if substr($arg, 0, 1) eq '/'
                || substr($arg, -1) eq '/'
                || index($arg, '//') != -1;

    # #7.  Also prohibits ".", which is OK for git-find since it is
    # fairly ambiguous between a ref/rev and a path.
    return false if substr($arg, -1) eq '.';

    #8
    return false if index($arg, '@{') != -1;

    #9 ('@') - ignore this one for simplicity in the rev test below.

    #10 - require the caller to check that

    # Extra: Prohibit refs that start with '--' since they are arguably
    # ambiguous with command-line options (and I can't make them work
    # with git anyway).
    return false if substr($arg, 0, 2) eq '--';

    return true;    # It's OK if we got here
} #_is_ref_ok()

#use re 'debug';

# Regex to match a rev or range of revs, i.e., something we should pass to git
my $_rev_regex =
    qr`(?xi)    # backtick delimiter because it doesn't occur in the regex text
        (?&RevRange)

        (?(DEFINE)

            (?<RevRange> ^(?:
                    # :/text, :/!-text, :/!!text
                    (?::/                   #(?{ print "# saw colon slash\n"; })
                        (?:
                                ![!\-](?:.+)    #(?{print "# 4\n";})
                            |   [^!].*          #(?{print "# 5\u";})
                        )
                    )

                    # :[n:]path.  NOTE: we prohibit starting the path with
                    # / if there is no number, in order to disambiguate
                    # the :/ text-search cases.
                |   :\d+:(?:.+)         #(?{print "# 2\n";})
                |   :[^/].*             #(?{print "# 3\n";})

                    # ^<rev>
                |   \^(?&Rev)           #(?{print "# 6\n";})

                    # rev:path
                |   (?&Rev):(?:.+)      #(?{print "# 7\n";})

                    # .. and ... differences, including x.., x..., x..y,
                    # and x...y.  Also handles the fallthrough
                    # of revrange->rev->ref.
                |   (?&Rev)(?:\.{2,3}(?&Rev)?)?
                                            #(?{print "# 8\n";})

                    # ..rev and ...rev
                |   \.{2,3}(?&Rev)

                    # at sign followed by braced item, and possibly
                    # preceded by a REF (not a rev).  E.g.,
                    # HEAD@{1}@{1} doesn't work.
                    # refname - at sign - braced item (date, #, branch, "push")
                |   (?&Ref)?\@\{[^\}]+\}
                                            #(?{print "# 9\n";})

                    # git-rev-parse "Options for Objects" forms
                |   --all
                |   --(?:branches|tags|remotes)(?:=.+)?
                |   --(?:glob|exclude)=.+
                |   --disambiguate=[0-9a-f]{4,40}

                    # git-rev-parse "Other Options" forms
                |   --(since|after|until|before)=.+

            )$) # End of RevRange

            (?<Rev> (?&Ref)(?&RefTrailer)* )
                    # This handles most of the cases.
                    # SHA1s, possibly abbreviated, are refs,
                    # as are git-describe outputs, whence RefTrailer*
                    # instead of RefTrailer+.

            (?<RefTrailer>
                    # For rev^[#] and rev~[#] forms
                    [~\^]\d*

                    # For rev^{} forms (empty braces OK)
                |   \^\{[^\}]*\}

                    # For rev^[@!] and rev^-n
                |   \^(?: \@ | ! | -\d* )
            ) # End of RefTrailer

            (?<Ref>
                (   \@      # '@' from git-rev-parse
                |   (?:[^\000-\037\177\ ~\^:\\?*\[.@/]
                            # git-check-ref-format #4, #5.
                            # [.@/] are handled below
                    | \.(?!\.)  # . ok, but .. prohibited
                    | \@(?!\{)  # @ ok, but @{ prohibited
                    | /(?!/)    # / ok, but // prohibited

                    )+?
                )
                (?(?{ _is_ref_ok($+) })|(?!))
                    # NOTE: $+ used since I couldn't get named capture groups
                    # with either %+ or %- to work
            ) # End of <Ref>

        ) #End of (DEFINE)

    `xi; # End of qr`...` and an extra backtick to unconfuse vim-eyapp: `

sub _is_valid_rev {
    my $arg = @_ ? $_[0] : $_;

    return false unless defined $arg and length($arg)>0;
    return scalar($arg =~ m{$_rev_regex});
} #_is_valid_rev()

# Get an expression element from the array passed in $_[0].
my $ARGTEST_cached = App::GitFind::Actions::ARGTEST();
sub _consume_expression_element {
    my $lrArgv = shift;
    my @retval;

    #say STDERR "# Trying >>$lrArgv->[0]<<";
    # TODO find(1) positional options, global options?

    # Regular options
    if($lrArgv->[0] =~ $ARGTEST_cached) {
        #say STDERR "#   - matched";
        my $arg = $1;
        my %opts = %{App::GitFind::Actions::argdetails($arg)};

        # Save any non-parser information from the argdetails to be
        # returned as part of the semantic value.
        my %extras = %opts;
        delete @extras{qw(token nparam)};

        # No-argument tests or actions
        unless($opts{nparam}>0) {
            #say STDERR "#   - No parameters";
            shift @$lrArgv;
            return ($opts{token} => { name => $arg, %extras })
        }

        # Consume additional arguments up to a regexp
        if(ref $opts{nparam} eq 'Regexp') {
            #say STDERR "#   - parameters until $opts{nparam}";
            die "Need argument(s) for --$arg" if @$lrArgv == 1;
            my $lastarg;
            #say STDERR "Args: ", join ' : ', @$lrArgv;
            for(1..$#$lrArgv) {
                $lastarg=$_, last if $lrArgv->[$_] =~ $opts{nparam};
            }
            die "--$arg needs an argument terminator matching $opts{nparam}"
                unless defined $lastarg;

            # Set up to fall through to the numeric-params case
            $opts{nparam} = $lastarg;
        }

        # Consume additional positional arguments
        #say STDERR "#   - $opts{nparam} parameters";
        die "Not enough parameters after --$arg (need $opts{nparam})"
            unless @$lrArgv >= ($opts{nparam}+1);   # +1 for $arg itself

        # Custom argument validation
        if($opts{validator}) {
            my $errmsg = $opts{validator}->(@{$lrArgv}[0..$opts{nparam}]);
            die "--$arg argument error: $errmsg" if defined($errmsg);
        }

        @retval = ($opts{token} => {
                        name => $arg,
                        params => [ @{$lrArgv}[1..$opts{nparam}] ],
                        %extras,
                    });
        splice @$lrArgv, 0, $opts{nparam}+1;
        return @retval;
    }

    # Operators
    my $arg = $lrArgv->[0];

    @retval = (COMMA => ',') if $arg eq ',';
    @retval = (OR => '-o') if $arg =~ /^(?:-o|--o|-or|--or|\|\|)$/;
    @retval = (AND => '-a') if $arg =~ /^(?:-a|--a|-and|--and|&&)$/;
    @retval = (NOT => '!') if $arg =~ /^(?:-not|--not|!|\^)$/;
    @retval = (LPAREN => '(') if $arg =~ /^[([]$/;
    @retval = (RPAREN => ')') if $arg =~ /^[])]$/;

    if(@retval) {
        shift @$lrArgv;
        return @retval;
    }

    return ();  # Not an expression element
} #_consume_expression_element

# Get a switch from the array passed in $_[0], if any.
# Removes the switch from the array if successful.
# Returns the token on success, and () on failure.
# TODO un-bundle switches; handle switches with args.
sub _consume_switch {
    my $lrArgv = shift;
    if($lrArgv->[0] =~ /^-([a-zA-z0-9\?])$/) {    # non-bundled switch
        shift @$lrArgv;
        return (SWITCH => $1)

    } elsif($lrArgv->[0] =~ /^--?(help|man|usage|version)$/) {
        # long switch, no args
        shift @$lrArgv;
        return (SWITCH => $1);

    } elsif($lrArgv->[0] =~ /^--?(git-dir|wd)=(.+)$/) {
        # long switch, one arg, with equals sign
        shift @$lrArgv;
        return (SWITCH => {$1=>$2});

    } elsif($lrArgv->[0] =~ /^--?(git-dir|wd)$/ && defined($lrArgv->[1])) {
        # long switch, one arg, without equals sign
        my $retval = {$1 => $lrArgv->[1]};
        splice @$lrArgv, 0, 2;
        return (SWITCH => $retval);
    }

    return ();
} #_consume_switch()

# Consume a rev from the array in $_[0]
sub _consume_rev {
    my $lrArgv = shift;
    my $arg = $lrArgv->[0];
    if(_is_valid_rev($arg)) {
        shift @$lrArgv;
        return (REV => $arg);
    }

    return ();
} #_consume_rev()

# }}}1
# Tokenizer and error-reporting routine for Parse::Yapp {{{1

# The lexer
sub _next_token {
    my $parser = shift;
    my $lrArgv = $parser->YYData->{ARGV};
    return ('', undef) unless @$lrArgv;     # EOF
    my @retval;     # The eventual token we will return

    # TODO? in the expression, split trailing commas into their
    # own arguments

    # Check for '--'
    if($lrArgv->[0] eq '--') {
        $parser->YYData->{ONLY_EXPRESSIONS} = true;
        return ('', undef) unless @$lrArgv > 1;
            # We are about to shift, so return EOF if this was the last arg.
        shift(@$lrArgv);
    }

    if($parser->YYData->{HAS_DASH_DASH}) {
        # Split-arg mode: don't look for expressions before '--', or
        # for switches or refs after '--'.
        if(!$parser->YYData->{ONLY_EXPRESSIONS}) {  # Look for switches/refs

            @retval = _consume_switch($lrArgv);
            return @retval if @retval;

            @retval = _consume_rev($lrArgv);
            if(@retval) {   # _consume_rev always gives us two elements
                if($retval[1] eq ']]') {
                    $parser->YYData->{SAW_RR} ||= true;
                } else {
                    $parser->YYData->{SAW_NON_RR} ||= true;
                }
                return @retval;
            }

            die "I don't understand argument '$lrArgv->[0]' before --";

        } else {                                    # Look for expressions
            @retval = _consume_expression_element($lrArgv);
            return @retval if @retval;
            die "I don't understand argument '$lrArgv->[0]' after --";
        }

    } else {
        # Merged-arg mode: any arg could be anything

        # Check for expressions.  Look for these before checking for refs so
        # that an expression that happens to look like a ref will be considered
        # an expression instead of a ref.
        my @retval = _consume_expression_element($lrArgv);
        return @retval if @retval;

        # Next, look for switches.  These are after expression elements
        # so that -a and -o will not be parsed as switches.
        @retval = _consume_switch($lrArgv);
        return @retval if @retval;

        # Last of all, revs.
        @retval = _consume_rev($lrArgv);
        if(@retval) {   # _consume_rev always gives us two elements
            if($retval[1] eq ']]') {
                $parser->YYData->{SAW_RR} ||= true;
            } else {
                $parser->YYData->{SAW_NON_RR} ||= true;
            }
            return @retval;
        }

        die "I don't understand argument $lrArgv->[0]";
    }

    die "Unexpected error while processing argument $lrArgv->[0]";   # Shouldn't happen
} #_next_token()

# Report an error
sub _report_error {
    my $parser = shift;
    my $got = $parser->YYCurtok || '<end of input>';
    my $val='';
    $val = ' (saw: ' . YYY($parser->YYCurval) . ')' if $parser->YYCurval;
    die "Syntax error: could not understand $got\n$val";
    if(ref($parser->YYExpect) eq 'ARRAY') {
        print 'Expected one of: ', join(',', @{$parser->YYExpect}), "\n";
    }
    return;
} #_report_error()

# }}}1
# Top-level parse function {{{1

=head2 Parse

Parse arguments.  Usage:

    my $hrArgs = App::GitFind::cmdline::Parse(\@ARGV);

Modifies the C<@ARGV> array.

=cut

sub Parse {
    my $lrArgv = shift or
        (require Carp, Carp::croak 'Parse: Need an argument list');

    my $parser = __PACKAGE__->new;
    my $hrData = $parser->YYData;

    # Data we use while parsing
    $hrData->{HAS_DASH_DASH} = !!(scalar grep { $_ eq '--' } @$lrArgv);
    $hrData->{ONLY_EXPRESSIONS} = false;    # true once we hit '--'
    $hrData->{ARGV} = $lrArgv;

    # Data we determine while parsing and return to the caller

    # Keep track of whether an action other than -prune has been seen.
    # If not, -print is added automatically.
    $hrData->{SAW_NON_PRUNE_ACTION} = false;

    # Keep track of the types of rev we've seen (]] or non-]])
    $hrData->{SAW_RR} = false;
    $hrData->{SAW_NON_RR} = false;

    my $hrRetval = $parser->YYParse(yylex => \&_next_token,
        yyerror => \&_report_error,
        (@_ ? (yydebug => $_[0]) : ()),
    );

    # Add non-AST data to the retval
    $hrRetval->{saw_nonprune_action} = $hrData->{SAW_NON_PRUNE_ACTION} if $hrRetval;
    $hrRetval->{saw_rr} = $hrData->{SAW_RR};
    $hrRetval->{saw_non_rr} = $hrData->{SAW_NON_RR};
    return $hrRetval;
} #Parse()

# }}}1
# Rest of the docs {{{1

=head1 AUTHOR

Christopher White C<< <cxw@cpan.org> >>

=head1 COPYRIGHT

MIT

=cut

# }}}1

# vi: set fdm=marker: #

1;
