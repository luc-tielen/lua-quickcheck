
# Contributing to lua-quickcheck

So you want to help out with lua-quickcheck? Great! Here's a brief overview on
how best to do so.

## Pull-requests

* New features
* Bugfixes
* Inefficient blocks of code
* ...

The [http://www.github.com/Primordus/lua-quickcheck.git/issues](issues)
contains a list of items that still need to be done.

If you have a more deeply-rooted problem with how the program is built or some
of the stylistic decisions made in the code, it's best to
[create an issue](https://github.com/Primordus/lua-quickcheck/issues) before putting
the effort into a pull request. The same goes for new features - it is
best to check the project's direction, existing pull requests and currently
open/closed issues first.

## Style

* Two spaces, not tabs
* Variables have_underscores, classes are Uppercase
* Wrap everything in `local`, expose blocks of code using the module pattern
* Olivine-Labs has a great [style guide](https://github.com/Olivine-Labs/lua-style-guide) 
  which can be used as a reference.

Look at existing code to get a good feel for the patterns we use. Please run
tests before submitting any pull requests. Instructions for running tests can
be found in the README.


## Using Git appropriately

1. Fork the repository.
2. Create a *topical branch* - a branch whose name is succint but explains what
   you're doing, such as "improved-generators"
3. Make your changes, committing at logical breaks.
4. Push your branch to your personal account
5. [Create a pull request](https://help.github.com/articles/using-pull-requests)
6. Watch for comments or acceptance

Please make separate branches for unrelated changes!


## Licensing

lua-quickcheck is MIT licensed. See details in the LICENSE file. This is a very permissive
scheme, GPL-compatible but without many of the restrictions of GPL.

