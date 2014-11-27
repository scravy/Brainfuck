This is brainfuck.
==================

An interpreter for the brianfuck programming language, written in C.
The interpreter is also capable of translating a Brainfuck program
into C and Ook!.

Building + Running
------------------

Use `make` for building (you'll need `make` and `gcc` installed) and `./bf -h`
for help.

Typical usage is `./bf file.bf`.

Installing
----------

`make install` will install to `$PREFIX/bin`.

Available command line options
------------------------------

    -m  memory size - defaults to 30000
    -b  buffer size (for reading from stdin)
    -r  run piece of code from command line arguments
    -o  translate to ook!
    -c  create c code
    -w  wrap pointer (only with -c)
    -p  don't check parenthesis (use with care)
    -h  this help
    -v  print version information

