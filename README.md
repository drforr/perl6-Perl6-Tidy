[![Build Status](https://travis-ci.org/drforr/perl6-Perl6-Tidy.svg?branch=master)](https://travis-ci.org/drforr/perl6-Perl6-Tidy)

NAME
====

Perl6::Tidy - Tidy Perl 6 source code according to your guidelines

SYNOPSIS
========

    my $pt = Perl6::Tidy.new(
        :strip-comments( False ),
        :strip-pod( False ),
        :strip-documentation( False ), # Superset of documentation and pod

        :indent-style( 'k-n-r' ),

    :indent-with-spaces( False ) # Indent with k-n-r style, spaces optional.

    );
    my $tidied = $pt.tidy( Q:to[_END_] );
       code-goes-here();
       that you( $want-to, $parse );
    _END_
    say $tidied;

    Indents code to match simple tab style (mine in this case).

    Choices of tab style include:
        'tab' (aka 1-true-brace-style or k-n-r)
        'Allman'
        'GNU'
        'Whitesmiths'
        'Horstmann'
        'Pico'
        'Ratliff'
        'Lisp'

    # This *will* execute phasers such as BEGIN in your existing code.
    # This may constitute a security hole, at least until the author figures
    # out how to truly make the Perl 6 grammar standalone.

DESCRIPTION
===========

Uses [Perl6::Parser](Perl6::Parser) to parse your source into a Perl 6 data structure, then walks the data structure and prints it according to your format guidelines.

Indentation
===========

Just as a reminder, here are quasi-formal names for common indentation styles.

'tab' - "One True Brace Style", "K&R":

while (x == y) { something(); somethingelse(); }

Allman:

while (x == y) { something(); somethingelse(); }

GNU:

while (x == y) { something(); somethingelse(); }

Whitesmiths:

while (x == y) { something(); somethingelse(); }

Horstmann

while (x == y) { something(); somethingelse(); }

Pico

while (x == y) { something(); somethingelse(); }

Ratliff

while (x == y) { something(); somethingelse(); }

Lisp

while (x == y) { something(); somethingelse(); }

METHODS
=======

  * tidy( Str $source )

Tidy the source code according to the guidelines set up in the constructor.

