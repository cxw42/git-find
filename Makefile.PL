#!perl
# Makefile.PL for App::GitFind
use 5.010;
use strict;
use warnings;
use Config;
use ExtUtils::MakeMaker;
use File::Spec;

my $VERSION_FROM = File::Spec->catfile(qw(lib App GitFind.pm)); # main code
my $SCRIPT = File::Spec->catfile(qw(script git-find));          # invoker
my $IS_TRIAL = check_trial();
my $secure_perl_path = get_perl_filename();
my @provides = ();

# Check if this is a TRIAL version {{{1
sub check_trial {
    TRIAL: {
        # Get the VERSION line
        open my $fd, '<', $VERSION_FROM or last TRIAL;
        my $linetext;
        while(<$fd>) {
            next unless /VERSION/;
            $linetext = $_;
            last;
        }
        close $fd;
        return !!($linetext =~ /\bTRIAL\b/);
    }
    return 0;
} #check_trial()

# }}}1
# Module metadata {{{1
eval {
    require Module::Metadata;
    @provides =
        (provides => Module::Metadata->provides(version => '2', dir => 'lib'));
        # Thanks to https://stackoverflow.com/a/28928985/2877364 by LEONT
        # for suggesting Module::Metadata.
};

# }}}1
# Get the filename of the Perl interpreter running this. {{{1
# Modified from perlvar.
# The -x test is for cygwin or other systems where $Config{perlpath} has no
# extension and $Config{_exe} is nonempty.  E.g., symlink perl->perl5.10.1.exe.
# There is no "perl.exe" on such a system.
sub get_perl_filename {
    my $secure_perl_path = $Config{perlpath};
    if ($^O ne 'VMS') {
        $secure_perl_path .= $Config{_exe}
            unless (-x $secure_perl_path) ||
                            ($secure_perl_path =~ m/$Config{_exe}$/i);
    }
    return $secure_perl_path;
} # get_perl_filename()

# }}}1
# Makefile customization (MY) {{{1
{   package MY;

    # dist_core: make `dist` a :: target rather than a : target,
    # and add distcheck before dist.
    sub dist_core {
        my $self = shift;
        my $text = $self->SUPER::dist_core(@_);
        $text =~ s/^dist\h*:[^:]/dist:: distcheck /m;

        return $text;
    } # MY::dist_core

    # Generate README.md; add uninstall target and other test targets
    sub postamble {     # TODO also handle Windows nmake syntax (SET vs. export)

        # Note: pod2markdown is marked with a hyphen so that `make` can
        # succeed and generate META files even if Pod::Markdown is not yet
        # installed.

        my $make_readme_md = File::Spec->catfile(qw(support readme.pl));
        return <<EOT;
authortest:
\tRELEASE_TESTING=1 prove -lvj4 xt

testhere:   # Run the tests from lib rather than blib
\tprove -lj4

README.md: @{[$VERSION_FROM]} Makefile.PL $make_readme_md
\t"$secure_perl_path" "$make_readme_md" -i "\$<" -o "\$@" -f md

README: @{[$VERSION_FROM]} Makefile.PL $make_readme_md
\t"$secure_perl_path" "$make_readme_md" -i "\$<" -o "\$@" -f text

# The following command line is rather bizarre so that it can be run on
# bash or cmd.  '\$\$' collapses to a single dollar sign, and the string eval
# is used to separate the dollar signs from the variable names so they will
# not trigger shell interpolation.  Double-quotes only, for compatibility
# with cmd, and no embedded double quotes (q() or qq() instead).

git-find.packed: @{[$VERSION_FROM]} @{[$SCRIPT]} Makefile.PL
\t"$secure_perl_path" -Ilib -MApp::FatPacker -MConfig -e "eval q(\$\$) . q(ENV{PERL5LIB}=join \$\$) . q(Config{path_sep}, \@INC;); App::FatPacker->new->run_script([q(pack), q($SCRIPT)])" > "\$@"

all :: README.md README git-find.packed
dist :: README.md README git-find.packed

# Uninstallation: mimic what the normal "uninstall" target does, but actually
# carry out the actions.
# Note: this may leave empty directories in place, since the packlist only
# includes files.

ACTUALLY_UNINSTALL = "$secure_perl_path" -MExtUtils::Install -e 'uninstall(shift,1)' --

actually_uninstall :: actually_uninstall_from_\$(INSTALLDIRS)dirs
\t\$(NOECHO) \$(NOOP)

actually_uninstall_from_perldirs ::
\t-\$(ACTUALLY_UNINSTALL) "\$(PERL_ARCHLIB)/auto/\$(FULLEXT)/.packlist"

actually_uninstall_from_sitedirs ::
\t-\$(ACTUALLY_UNINSTALL) "\$(SITEARCHEXP)/auto/\$(FULLEXT)/.packlist"

actually_uninstall_from_vendordirs ::
\t-\$(ACTUALLY_UNINSTALL) "\$(VENDORARCHEXP)/auto/\$(FULLEXT)/.packlist"

EOT

    } #postamble()
} #package MY

# }}}1

# Main options for EUMM
my %opts = (
    NAME             => 'App::GitFind',
    AUTHOR           => q{Christopher White <cxw@cpan.org>},
    VERSION_FROM     => $VERSION_FROM,
    ABSTRACT_FROM    => $VERSION_FROM,
    LICENSE          => 'mit',
    PL_FILES         => {},
    MIN_PERL_VERSION => '5.010',

    # In the following, if a specific version is listed, but no explanation
    # is given, that means we want that version for bugfixes it includes.
    CONFIGURE_REQUIRES => {
        'Config' => '0',
        'ExtUtils::MakeMaker' => '0',
        'File::Spec' => '0',
        'strict' => '0',
        'warnings' => '0',
    },
    BUILD_REQUIRES => {
        'App::FatPacker' => '0.009016',
        'Getopt::Long' => '2.5',
        'Path::Class' => '0.37',
        'Pod::Markdown' => '0',     # pod2markdown
        'Pod::Text' => '0',         # pod2text
    },
    TEST_REQUIRES => {
        'Carp' => '0',
        'Exporter' => '0',
        #'Import::Into' => '0',
        #'rlib' => '0',
        #'Scalar::Util' => '0',
        #'Test::Deep' => '0.084',        # for superhashof
        #'Test::Directory' => '0.02',    # for subdirs
        #'Test::Exception' => '0',
        'Test::More' => '0',
        # Test::TempDir::Tiny?  If so, remove Test::Directory dependency?
        #'Test::Warn' => '0.35',     # for metadata
    },
    PREREQ_PM => {
        #'Class::Method::Modifiers' => '2.10',   # most recent code change
        #'Class::Tiny' => '1.000',   # New API.  NOTE: <1.001 has no BUILDARGS

        #'Class::Tiny::ConstrainedAccessor' => '0.000010',   # custom constraints

        #'Config' => '0',
        #'Cwd' => '0',

        #'constant' => '0',
        #'Data::Dumper' => '2.154',      # For Maxrecurse
        #'Exporter' => '0',
        #'feature' => '0',
        # 'File::Find::Rule' => '0',    # - might be nice for finding files
        #'File::Glob' => '0',
        #'File::Globstar' => '0.5',      # Fewer dependencies
        #'File::Path::Tiny' => '0.9',
        #'File::pushd' => '1.013',
        #'File::Spec' => '0',
        #'File::stat' => '0',
        #'File::Which' => '1.22',    # for msys2 support
        'Git' => '0.40',
        #'Hash::Merge' => '0.299',
        #'Hash::Ordered' => '0.011',
        #'Import::Into' => '0',
        #'Getargs::Mixed' => '1.04', # For -undef_ok option

        # 'Module::Find' => '0.12', # For bugfixes
                                    # - Use for finding plugins to load.
                                    # - May also need Module::Runtime.
                                    # - Alternative is Module::Pluggable,
                                    #   but that appears to have more test
                                    #   failures.

        # 'Number::Compare' => '0', # - looks cool

        #'overload' => '0',

        # 'Parse::RecDescent' => '1.967015',
            # - Use for parsing Lua tables as inline config data?
            #   I am thinking about using this for specifying flavors at
            #   build time.  E.g., `--flavor debug=1,["+"]=42`.
            # - Syntax at https://www.lua.org/pil/3.6.html .
            # - See https://www.perlmonks.org/?node_id=462581 for operator
            #   precedence in P::RD grammars.

        'Path::Class' => '0.37',
        'Pod::Usage' => '0',
        # 'Probe::Perl' => '0', # For perl interpreter file location or other info.
                                # Alternative: Padre::Perl

        #'Quote::Code' => '1.01',
        #'Role::Tiny' => '1.000000',

        #'Scalar::Util' => '0',
        #'Set::Scalar' => '1.27',    # For correct metadata
        ## 'Storable' => '3.06',
            # So it can handle REGEXP -
            # https://rt.perl.org/Public/Bug/Display.html?id=50608

        #'String::Print' => '0.92',
        # 'Sub::ScopeFinalizer' => '0.02',        # For correct META.yml

        #'Syntax::Construct' => '0.07',
        #'Type::Tiny' => '1.004004',

        'vars::i' => '1.06',
    },

    META_MERGE => {
        'meta-spec' => { version => 2 },

        resources => {
            bugtracker => {
                web  => 'https://github.com/cxw42/git-find/issues',
            },
            repository => {
                type => 'git',
                url  => 'https://github.com/cxw42/git-find.git',
                web  => 'https://github.com/cxw42/git-find',
            },
        },

        prereqs => {
            develop => {
                requires => {
                    'App::RewriteVersion' => '0',   # for perl-bump-version
                    'Module::Metadata' => '1.000016',
                    'Test::Kwalitee' => '0',
                },
            },
        },

        @provides,

    }, #META_MERGE

    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'App-GitFind-*' },
); # %opts

if($IS_TRIAL) {
    print STDERR "TRIAL version\n";
    $opts{META_MERGE}->{release_status} = 'testing';
    $opts{DISTVNAME} = '$(DISTNAME)-$(VERSION)-TRIAL';
}

# Some tests run on older versions of EUMM that do not support TEST_REQUIRES.
# This is a workaround, modified from
# https://metacpan.org/source/RJBS/JSON-Typist-0.005/Makefile.PL ,
# linked from http://blogs.perl.org/users/neilb/2017/05/specifying-dependencies-for-your-cpan-distribution.html .
# If we are on a version of EUMM that doesn't support TEST_REQUIRES,
# move those dependencies to PREREQ_PM.
unless( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
    $opts{PREREQ_PM}->{$_} = $opts{TEST_REQUIRES}->{$_}
        foreach keys %{$opts{TEST_REQUIRES}};
    delete $opts{TEST_REQUIRES};
}

WriteMakefile(%opts);
# vi: set fdm=marker fdl=0: #
