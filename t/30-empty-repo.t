use strict;
use warnings;
use lib::relative '.';
use TestKit;

use App::GitFind;
use Capture::Tiny qw(capture);

my $repo = make_git_repo;

my ($stdout, $stderr, $exit) = capture {
    App::GitFind->new(-argv => [$repo->wc_path], -searchbase=>$repo->wc_path)->run;
};
is $exit, number(0), 'Success';
is $stdout, '', 'No files found (as expected in an empty repo)';

done_testing;
