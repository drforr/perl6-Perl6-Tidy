=begin pod

=begin NAME

Perl6::Tidy - Tidy Perl 6 source code according to your guidelines

=end NAME

=begin SYNOPSIS

    my $pt = Perl6::Tidy.new(
        :strip-comments( False ),
        :strip-pod( False ),
        :strip-documentation( False ), # Superset of documentation and pod

        :indent-style( 'tab' ),
	:indent-with-spaces( False ) # Indent using tabs, spaces are optional.
    );
    my $tidied = $pt.tidy( Q:to[_END_] );
       code-goes-here();
       that you( $want-to, $parse );
    _END_
    say $tidied;

    Indents code to match simple tab style (mine in this case).

    Choices of tab style include:
        'tab' (aka 1-true-brace-style')
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

    'tab' - "One True Brace Style":

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

subset Indent-Style of Str where * eq
	'none'  |
	'tab'   |
	'space' |
	'Allman' |
	'GNU' |
	'Whitesmiths' |
	'Horstmann' |
	'Ratliff' |
	'Pico' |
	'Lisp'
;

subset Indent-Amount of Positive-Int;

constant TAB-STOP-IN-SPACES = 8;

role Spare-Tokens {
	method tab-character {
		return ' ' x TAB-STOP-IN-SPACES if $.indent-with-spaces;
		return "\t";
	}

	method spare-newline {
		Perl6::Newline.new( :from( 0 ), :to( 0 ), :content( "\n" ) );
	}

	method spare-space {
		Perl6::WS.new( :from( 0 ), :to( 0 ), :content( " " ) );
	}

	method spare-half-tab {
		my $half-tab = ' ' x floor( TAB-STOP-IN-SPACES / 2 );
		Perl6::WS.new(
			:from( 0 ),
			:to( 0 ),
			:content( $half-tab )
		);
	}

	method spare-tab {
		Perl6::WS.new(
			:from( 0 ),
			:to( 0 ),
			:content( self.tab-character )
		);
	}

	method spare-indent( Int $depth ) {
		Perl6::WS.new(
			:from( 0 ),
			:to( 0 ),
			:content( self.tab-character x $depth )
		);
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

	has Perl6::Element @.token;

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

		method delete-behind {
			@.token.splice( $.index - 1, 1 );
			self.move(-1);
		}
		method delete-behind-by-type( Perl6::Element $type ) {
			while self.peek( -1 ) ~~ $type {
				self.delete-behind;
			}
		}
		method delete-self {
			@.token.splice( $.index, 1 );
			self.move(-1);
		}
		method delete-ahead {
			@.token.splice( $.index + 1, 1 );
		}
		method delete-ahead-by-type( Perl6::Element $type ) {
			while self.peek ~~ $type {
				self.delete-ahead;
			}
		}

		method add-behind( *@token ) {
			@.token.splice( $.index, 0, @token );
			self.move( @token.elems );
		}
		method add-ahead( *@token ) {
			@.token.splice( $.index + 1, 0, @token );
		}
	}

	method reflow-open-brace( CursorList $token ) {
		given $.indent-style {
			when 'tab' | 'Ratliff' | 'Lisp' {
				$token.delete-behind-by-type(
					Perl6::Invisible
				);
				$token.delete-ahead-by-type(
					Perl6::Invisible
				);
				$token.add-behind(
					self.spare-space
				);
				$token.add-ahead(
					self.spare-newline,
					self.spare-indent(
						$.brace-depth
					)
				);
			}
			when 'Allman' {
				$token.delete-behind-by-type(
					Perl6::Invisible
				);
				$token.delete-ahead-by-type(
					Perl6::Invisible
				);
				$token.add-behind(
					self.spare-newline,
					self.spare-indent(
						$.brace-depth - 1
					)
				);
				$token.add-ahead(
					self.spare-newline,
					self.spare-indent(
						$.brace-depth
					)
				);
			}
			when 'GNU' {
				$token.delete-behind-by-type(
					Perl6::Invisible
				);
				$token.delete-ahead-by-type(
					Perl6::Invisible
				);
				$token.add-behind(
					self.spare-newline,
					self.spare-indent(
						$.brace-depth - 1
					),
					self.spare-half-tab
				);
				$token.add-ahead(
					self.spare-newline,
					self.spare-indent(
						$.brace-depth
					)
				);
			}
			when 'Whitesmiths' {
				$token.delete-behind-by-type(
					Perl6::Invisible
				);
				$token.delete-ahead-by-type(
					Perl6::Invisible
				);
				$token.add-behind(
					self.spare-newline,
					self.spare-indent(
						$.brace-depth
					)
				);
				$token.add-ahead(
					self.spare-newline,
					self.spare-indent(
						$.brace-depth
					)
				);
			}
			when 'Horstmann' | 'Pico' {
				$token.delete-behind-by-type(
					Perl6::Invisible
				);
				$token.delete-ahead-by-type(
					Perl6::Invisible
				);
				$token.add-behind(
					self.spare-newline,
					self.spare-indent(
						$.brace-depth - 1
					)
				);
				$token.add-ahead(
					self.spare-indent(
						$.brace-depth
					)
				);
			}
		}
	}

	method reflow-semicolon( CursorList $token ) {
		given $.indent-style {
			when 'tab' | 'Allman' | 'GNU' | 'Whitesmiths' | 'Horstmann' | 'Ratliff' | 'Lisp' {
				$token.delete-behind-by-type(
					Perl6::Invisible
				);
				$token.delete-ahead-by-type(
					Perl6::Invisible
				);
				$token.add-ahead(
					self.spare-newline,
					self.spare-indent(
						$.brace-depth
					)
				);
			}
			when 'Pico' {
				$token.delete-behind-by-type(
					Perl6::Invisible
				);
				$token.delete-ahead-by-type(
					Perl6::Invisible
				);
				$token.add-ahead(
					self.spare-newline,
					self.spare-indent(
						$.brace-depth
					)
				);
			}
		}
	}

	method reflow-close-brace( CursorList $token ) {
		given $.indent-style {
			when 'tab' | 'Allman' | 'Horstmann' {
				$token.delete-behind-by-type(
					Perl6::Invisible
				);
				$token.delete-ahead-by-type(
					Perl6::Invisible
				);
				$token.add-behind(
					self.spare-newline,
					self.spare-indent(
						$.brace-depth
					)
				);
				if !$token.is-end {
					$token.add-ahead(
						self.spare-newline
					);
				}
			}
			when 'GNU' {
				$token.delete-behind-by-type(
					Perl6::Invisible
				);
				$token.delete-ahead-by-type(
					Perl6::Invisible
				);
				$token.add-behind(
					self.spare-newline,
					self.spare-indent(
						$.brace-depth
					),
					self.spare-half-tab
				);
				if !$token.is-end {
					$token.add-ahead(
						self.spare-newline
					);
				}
			}
			when 'Whitesmiths' {
				$token.delete-behind-by-type(
					Perl6::Invisible
				);
				$token.delete-ahead-by-type(
					Perl6::Invisible
				);
				$token.add-behind(
					self.spare-newline,
					self.spare-indent(
						$.brace-depth + 1
					),
				);
				if !$token.is-end {
					$token.add-ahead(
						self.spare-newline
					);
				}
			}
			when 'Pico' | 'Lisp' {
				$token.delete-behind-by-type(
					Perl6::Invisible
				);
				$token.delete-ahead-by-type(
					Perl6::Invisible
				);
				$token.add-behind(
					self.spare-space
				);
				if !$token.is-end {
					$token.add-ahead(
						self.spare-newline
					);
				}
			}
			when 'Ratliff' {
				$token.delete-behind-by-type(
					Perl6::Invisible
				);
				$token.delete-ahead-by-type(
					Perl6::Invisible
				);
				$token.add-behind(
					self.spare-newline,
					self.spare-indent(
						$.brace-depth + 1
					)
				);
				if !$token.is-end {
					$token.add-ahead(
						self.spare-newline
					);
				}
			}
		}
	}

	method tidy( Str $source ) {
		my @token = $.parser.to-tokens-only( $source );
		my $token = CursorList.from-list( @token );

		while !$token.loop-done {
			self.update-indent( $token.current );
			given $token.current {
				when Perl6::Pod {
					if $.strip-pod or
						$.strip-documentation {
						$token.delete-behind-by-type(
							Perl6::Invisible
						);
						$token.delete-self;
					}
				}
				when Perl6::Comment {
					if $.strip-comments or
						$.strip-documentation {
						$token.delete-behind-by-type(
							Perl6::Invisible
						);
						$token.delete-self;
					}
				}
				when Perl6::Block::Enter {
					self.reflow-open-brace( $token );
				}
				when Perl6::Semicolon {
					self.reflow-semicolon( $token );
				}
				when Perl6::Block::Exit {
					self.reflow-close-brace( $token );
				}
			}
			$token.move;
		}

		my $iterated = '';
		for $token.token {
			$iterated ~= $_.content;
		}
		$iterated;
	}
}

# I'd love to come up with a better solution that lets me clean up
# $.{brace,bracket..}-depth with no boilerplate.
#
class Perl6::Tidy {
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
