# Contributing to git-find

Thank you for your interest and help!

## Finding issues

* Start with issues labeled `hacktoberfest`.
* If you are relatively new to Perl, start with the issues that are
  _also_ labeled `good first issue`.

## Getting set up with Perl and the dependencies

I recommend using [cpanminus](https://metacpan.org/pod/distribution/App-cpanminus/lib/App/cpanminus/fatscript.pm) to install the dependencies.

Fork on GitHub, and then:

    git clone https://github.com/<your name>/git-find.git
    cd git-find
    cpanm --installdeps --with-develop --with-recommends .

Some useful articles:

Getting started with Perl:

- <https://learn.perl.org/installing/>
- <https://learn.perl.org/first_steps/>
- <https://perlmaven.com/installing-perl-and-getting-started>

Setting up and using cpanminus:

- <https://perlmaven.com/how-to-install-a-perl-module-from-cpan>
- <https://www.linode.com/docs/development/perl/manage-cpan-modules-with-cpan-minus/>

## Development

This project uses the standard Perl workflow.

To build and test:

    perl Makefile.PL
    make
    make test

This builds the package into `blib/` and runs tests against that built
version.

To test iteratively while developing, run:

    prove -l

You don't have to run `perl Makefile.PL` or `make` --- this just runs the
tests against the current contents of your source tree.

If you are testing the parser, run

    make yapp && prove -l

instead.  This will make sure the latest parser changes have been applied
to the `lib/` tree.

## Licensing

git-find is licensed under the MIT license.  As part of your first PR, please
add a "Portions copyright `your name`" line to the [LICENSE](LICENSE) file.
