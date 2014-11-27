This is brainfuck.
==================

An interpreter for the brianfuck programming language, written in Haskell.

Running
--------

Use `cabal run` for running the project (You need to have the Haskell
Platform installed).

Compiling + Running
-------------------

Use `cabal build` for building the project. You can then run the executable:

    ./dist/build/bf/bf

Installing
----------

Use `cabal install` for installing the `bf` executable. Make sure that
the default cabal bin installation directory is in your `$PATH`.

Available command line options
------------------------------

    -p  Pretty print the parse tree
    -o  Pretty print the optimized parse tree
    -s  Run slow (does not perform any optimizations)


