# Note: if you enable debug output from App::GitFind, the test will fail
# because the output will be nonempty.
#use Sub::Multi::Tiny::Util qw(*VERBOSE);
#BEGIN { $VERBOSE = 99; $Data::Dumper::Indent = 1;}
#BEGIN { $App::GitFind::cmdline::SHOW_AST = 1; }

use strict;
use warnings;
use lib::relative '.';
use TestKit;

use App::GitFind;
use Capture::Tiny qw(capture);

my $repo = make_git_repo;

#--wd<space>...
my ($stdout, $stderr, $exit) = capture {
    App::GitFind->new(-argv => ['--wd', $repo->wc_path], -searchbase=>$repo->wc_path)->run;
};
is $exit, number(0), 'Success';
is $stdout, '', 'No files found (as expected in an empty repo)';

# --wd=...
($stdout, $stderr, $exit) = capture {
    App::GitFind->new(-argv => ['--wd=' . $repo->wc_path], -searchbase=>$repo->wc_path)->run;
};
is $exit, number(0), 'Success';
is $stdout, '', 'No files found (as expected in an empty repo)';

done_testing;
