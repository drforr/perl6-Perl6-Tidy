=begin pod

=begin NAME

Perl6::Tidy - Tidy Perl 6 source code according to your guidelines

=end NAME

=begin SYNOPSIS

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

=end SYNOPSIS

=begin DESCRIPTION

Uses L<Perl6::Parser> to parse your source into a Perl 6 data structure, then walks the data structure and prints it according to your format guidelines.

=begin Indentation

Just as a reminder, here are quasi-formal names for common indentation styles.

    'tab' - "One True Brace Style", "K&R":

    while (x == y) {
        something();
        somethingelse();
    }

    Allman:

    while (x == y)
    {
        something();
        somethingelse();
    }

    GNU:

    while (x == y)
      {
        something();
        somethingelse();
      }

    Whitesmiths:

    while (x == y)
        {
        something();
        somethingelse();
        }

    Horstmann

    while (x == y)
    {   something();
        somethingelse();
    }

    Pico

    while (x == y)
    {   something();
        somethingelse(); }

    Ratliff

    while (x == y) {
        something();
        somethingelse();
        }

    Lisp

    while (x == y) {
        something();
        somethingelse(); }

=end Indentation

=end DESCRIPTION

=begin METHODS

=item tidy( Str $source )

Tidy the source code according to the guidelines set up in the constructor.

=end METHODS

=end pod

use Perl6::Parser;

subset Non-Negative-Int of Int where * > -1;
subset Positive-Int of Int where * > 0;

# This doesn't quite work as well when you have "aliases" for a given
# indent-style. Of course, the answer is another abstraction layer.
#
subset Indent-Style of Str where * eq
	'none'        |
	'tab'         |
	'k-n-r'       |
	'Allman'      |
	'GNU'         |
	'Whitesmiths' |
	'Horstmann'   |
	'Ratliff'     |
	'Pico'        |
	'Lisp'
;

subset Indent-Amount of Positive-Int;

constant TAB-STOP-IN-SPACES = 8;

role Spare-Tokens {
	method _tab( Int $count = 1 ) { 
		my $tab = $.indent-with-spaces ??
			' ' x TAB-STOP-IN-SPACES !!
			"\t";
		$tab x $count;
	}

	method spare-newline {
		Perl6::Newline.new(
			:from( 0 ),
			:to( 0 ),
			:content( "\n" )
		);
	}

	method spare-space {
		Perl6::WS.new(
			:from( 0 ),
			:to( 0 ),
			:content( " " )
		);
	}

	method spare-indent( Int $depth ) {
		Perl6::WS.new(
			:from( 0 ),
			:to( 0 ),
			:content( self._tab( $depth ) )
		);
	}

	# "\t\t    " is a single WS token.
	#
	method spare-indent-and-a-half( Int $depth ) {
		my $half-tab =
			' ' x floor( TAB-STOP-IN-SPACES / 2 );
		Perl6::WS.new(
			:from( 0 ),
			:to( 0 ),
			:content( ( self._tab( $depth ) ) ~ $half-tab )
		);
	}
}

# Lets you "walk" the array as if you have a virtual edit "cursor".
#
# Deleting entries behind the "cursor" moves the cursor backwards.
# Deleting entries in front of the "cursor" has no effect.
# Adding entries behind the "cursor" moves the cursor forwards.
# Adding entries in front of the cursor has no effect. (*)
# 
# * Arguably it should move the cursor forwards, as you presumably
#   don't want to iterate over what you've just inserted.
#
my class CursorList {
	has $.index = 0;
	has @.token;

	method clamp {
		$!index = 0 if $.index < 0;
		$!index = @.token.end if $.index > @.token.end;
	}

	method from-list( @token ) {
		self.bless( :token( @token ) )
	}

	method to-string {
		my $document = '';
		$document ~= $_.content for @.token;
		$document;
	}

	# let 'move' move outside the array.
	# That way 'loop-done' will terminate correctly.
	#
	method move( Int $amount = 1 ) {
		$!index += $amount;
	}
	method loop-done { $.index > @.token.end; }

	method is-end { $.index == @.token.end; }

	method peek( Int $amount = 1 ) {
		return Any if $.index + $amount > @.token.end;
		return Any if $.index + $amount < 0;
		@.token[$.index + $amount];
	}

	method current { @.token[$.index] }

	method replace-with( Perl6::Element $node ) {
		@.token.splice( $.index, 1, $node )
	}

	method delete-behind {
		@.token.splice( $.index - 1, 1 );
		self.move(-1);
	}
	method delete-behind-by-type( Perl6::Element $type ) {
		self.delete-behind
			while self.peek( -1 ) ~~ $type;
	}
	method delete-self {
		@.token.splice( $.index, 1 );
		self.move(-1);
	}
	method delete-ahead {
		@.token.splice( $.index + 1, 1 );
	}
	method delete-ahead-by-type( Perl6::Element $type ) {
		self.delete-ahead
			while self.peek ~~ $type;
	}

	method delete-around-by-type( Perl6::Element $type ) {
		self.delete-behind-by-type( $type );
		self.delete-ahead-by-type( $type );
	}

	method add-behind( *@token ) {
		@.token.splice( $.index, 0, @token );
		self.move( @token.elems );
	}
	method add-ahead( *@token ) {
		@.token.splice( $.index + 1, 0, @token );
		self.move( @token.elems );
	}
}

class Perl6::Tidy::Internals {
	also does Spare-Tokens;

	has Bool          $.strip-comments is required;
	has Bool          $.strip-pod is required;
	has Bool          $.strip-documentation is required;

	has Indent-Style  $.indent-style is required;
	has Bool	  $.indent-with-spaces is required;
	has Indent-Amount $.indent-amount is required;

	has Perl6::Parser $.parser = Perl6::Parser.new;

	has Non-Negative-Int $.brace-depth = 0;
	has Non-Negative-Int $.pointy-depth = 0;
	has Non-Negative-Int $.square-depth = 0;
	has Non-Negative-Int $.paren-depth = 0;

	has CursorList $.cursor;

	method debug-indent {
		"\{: $.brace-depth; " ~
		"\<: $.pointy-depth; " ~
		"\[: $.square-depth; " ~
		"\(: $.paren-depth;";
	}

	# Use REs to match the braces because ':(..)' is valid.
	#
	method update-indent( Perl6::Element $token ) {
		given $token {
			when Perl6::Block::Enter { $!brace-depth++ }
			when Perl6::Balanced::Enter {
				given $token.content {
					when /\(/ { $!paren-depth++ }
					when /\[/ { $!square-depth++ }
					when /\</ { $!pointy-depth++ }
					default {
						die "Unknown open balanced";
					}
				}
			}
			when Perl6::Block::Exit { $!brace-depth-- }
			when Perl6::Balanced::Exit {
				given $token.content {
					when /\)/ { $!paren-depth-- }
					when /\]/ { $!square-depth-- }
					when /\>/ { $!pointy-depth-- }
					default {
						die "Unknown open balanced";
					}
				}
			}
		}
	}

	method reflow-pod {
		if $.strip-pod or $.strip-documentation {
			$.cursor.delete-behind-by-type( Perl6::Invisible );
			$.cursor.delete-self;
		}
	}

	method reflow-comment {
		if $.strip-comments or $.strip-documentation {
			$.cursor.delete-behind-by-type( Perl6::Invisible );
			$.cursor.delete-self;
		}
	}

	method reflow-open-brace {
		if $.indent-style ne 'none' {
			$.cursor.delete-around-by-type( Perl6::Invisible );
		}
		given $.indent-style {
			when 'tab' | 'k-n-r' | 'Ratliff' | 'Lisp' {
				$.cursor.add-behind( self.spare-space );
				$.cursor.add-ahead(
					self.spare-newline,
					self.spare-indent( $.brace-depth )
				);
			}
			when 'Allman' {
				$.cursor.add-behind(
					self.spare-newline,
					self.spare-indent( $.brace-depth - 1 )
				);
				$.cursor.add-ahead(
					self.spare-newline,
					self.spare-indent( $.brace-depth )
				);
			}
			when 'GNU' {
				$.cursor.add-behind(
					self.spare-newline,
					self.spare-indent-and-a-half(
						$.brace-depth - 1
					)
				);
				$.cursor.add-ahead(
					self.spare-newline,
					self.spare-indent( $.brace-depth )
				);
			}
			when 'Whitesmiths' {
				$.cursor.add-behind(
					self.spare-newline,
					self.spare-indent( $.brace-depth )
				);
				$.cursor.add-ahead(
					self.spare-newline,
					self.spare-indent( $.brace-depth )
				);
			}
			when 'Horstmann' | 'Pico' {
				$.cursor.add-behind(
					self.spare-newline,
					self.spare-indent( $.brace-depth - 1 )
				);
				$.cursor.add-ahead(
					self.spare-indent( $.brace-depth )
				);
			}
		}
	}

	method reflow-whitespace {
		if $.indent-style ne 'none' {
			$.cursor.delete-around-by-type( Perl6::Invisible );
		}
		given $.indent-style {
			when 'tab' | 'k-n-r' | 'Allman' | 'GNU' |
				'Whitesmiths' | 'Horstmann' | 'Ratliff' |
				'Pico' | 'Lisp' {
				$.cursor.replace-with( self.spare-space );
			}
		}
	}

	method reflow-semicolon {
		if $.indent-style ne 'none' {
			$.cursor.delete-around-by-type( Perl6::Invisible );
		}
		given $.indent-style {
			when 'tab' | 'k-n-r' | 'Allman' | 'GNU' |
				'Whitesmiths' | 'Horstmann' | 'Ratliff' |
				'Pico' | 'Lisp' {
				$.cursor.add-ahead(
					self.spare-newline,
					self.spare-indent( $.brace-depth )
				);
			}
		}
	}

	method reflow-close-brace {
		if $.indent-style ne 'none' {
			$.cursor.delete-around-by-type( Perl6::Invisible );
		}
		given $.indent-style {
			when 'tab' | 'k-n-r' | 'Allman' | 'Horstmann' {
				$.cursor.add-behind(
					self.spare-newline,
					self.spare-indent( $.brace-depth )
				);
			}
			when 'GNU' {
				$.cursor.add-behind(
					self.spare-newline,
					self.spare-indent-and-a-half(
						$.brace-depth
					)
				);
			}
			when 'Whitesmiths' | 'Ratliff' {
				$.cursor.add-behind(
					self.spare-newline,
					self.spare-indent( $.brace-depth + 1 )
				);
			}
			when 'Pico' | 'Lisp' {
				$.cursor.add-behind( self.spare-space );
			}
		}
		if $.indent-style ne 'none' {
			if !$.cursor.is-end {
				$.cursor.add-ahead( self.spare-newline );
			}
		}
	}

	method tidy( Str $source ) {
		my @token = $.parser.to-tokens-only( $source );
		$!cursor = CursorList.from-list( @token );

		while !$.cursor.loop-done {
			self.update-indent( $.cursor.current );
			given $.cursor.current {
				when Perl6::Pod {
					self.reflow-pod;
				}
				when Perl6::Comment {
					self.reflow-comment;
				}
				when Perl6::Block::Enter {
					self.reflow-open-brace;
				}
				when Perl6::Semicolon {
					self.reflow-semicolon;
				}
				when Perl6::WS {
					self.reflow-whitespace;
				}
				when Perl6::Block::Exit {
					self.reflow-close-brace;
				}
			}
			$.cursor.move;
		}

		$.cursor.to-string;
	}
}

# I'd love to come up with a better solution that lets me clean up
# $.{brace,bracket..}-depth with no boilerplate.
#
class Perl6::Tidy:ver<0.0.1>  {
	has Bool          $.strip-comments = False;
	has Bool          $.strip-pod = False;
	has Bool          $.strip-documentation = False;

	has Indent-Style  $.indent-style = 'none';
	has Bool	  $.indent-with-spaces = False;
	has Indent-Amount $.indent-amount = 1;

	method tidy( Str $source ) {
		my $internals = Perl6::Tidy::Internals.new(
			:strip-comments( $.strip-comments ),
			:strip-pod( $.strip-pod ),
			:strip-documentation( $.strip-documentation ),
			:indent-style( $.indent-style ),
			:indent-with-spaces( $.indent-with-spaces ),
			:indent-amount( $.indent-amount )
		);
		$internals.tidy( $source );
	}
}
