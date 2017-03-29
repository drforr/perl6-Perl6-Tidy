=begin pod

=begin NAME

Perl6::Tidy - Tidy Perl 6 source code according to your guidelines

=end NAME

=begin SYNOPSIS

    my $pt = Perl6::Tidy.new(
        :strip-comments( False ),
        :strip-pod( False ),
        :strip-documentation( False ), # Superset of documentation and pod

        :indent-style( 'tab' )
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

role Edit-Tokens {
	method indent-in-spaces {
		return TAB-STOP-IN-SPACES if $.indent-style ne 'space';
		return $.indent-size;
	}

	method spare-newline {
		Perl6::Newline.new( :from( 0 ), :to( 0 ), :content( "\n" ) );
	}
	method spare-space {
		Perl6::WS.new( :from( 0 ), :to( 0 ), :content( " " ) );
	}
	method spare-tab {
		my $content = '';
		if $.indent-style eq 'spaces' {
			$content = ' ' x self.indent-in-spaces;
		}
		else {
			$content = "\t";
		}
		Perl6::WS.new( :from( 0 ), :to( 0 ), :content( $content ) );
	}
	method spare-half-tab {
		my $indent-in-spaces = self.indent-in-spaces;
		Perl6::WS.new(
			:from( 0 ),
			:to( 0 ),
			:content( " " x int( $indent-in-spaces / 2 ) ) );
	}
	method spare-indent( Int $depth ) {
		my $spaces = "\t";
		$spaces = ' ' x $.indent-size if
			$.indent-style eq 'spaces';

		Perl6::WS.new(
			:from( 0 ),
			:to( 0 ),
			:content( $spaces x $depth )
		);
	}

	method _num-whitespace-tokens-after( Int $index ) {
		my $_index = $index;
		my $count = 0;
		$count++ while @.token[++$_index] ~~ Perl6::Invisible;
		$count;
	}
	method _num-whitespace-tokens-before( Int $index ) {
		my $_index = $index;
		my $count = 0;
		$count++ while @.token[--$_index] ~~ Perl6::Invisible;
		$count;
	}

	method require-ws-token-after( Int $index, *@token ) {
		if $index >= @.token.elems or
			@.token[$index + 1] !~~ Perl6::Newline {
			@.token.splice( $index + 1, 0, @token );
		}
		elsif @.token[$index + 1] ~~ Perl6::WS {
			my $splice-size =
				self._num-whitespace-tokens-after( $index );
			#@.token.splice( $index + 1, $splice-size, @token );
			@.token.splice( $index, $splice-size, @token );
		}
	}

	method require-ws-token-before( Int $index, *@token ) {
		if $index <= 0 {
			@.token.splice( $index, 0, @token );
		}
		elsif @.token[$index - 1] ~~ Perl6::Invisible {
			my $splice-size =
				self._num-whitespace-tokens-before( $index );
			@.token.splice( $index - 1, $splice-size, @token );
		}
		else {
			@.token.splice( $index, 0, @token );
		}
	}
}

class Perl6::Tidy::Internals {
	also does Edit-Tokens;

	# Create constants so that editors don't freak out.
	#
	constant OPEN-BRACE = '{';
	constant CLOSE-BRACE = '}';

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
			when Perl6::Balanced::Enter {
				given $token.content {
					when /\{/ { $!brace-depth++ }
					when /\(/ { $!paren-depth++ }
					when /\[/ { $!square-depth++ }
					when /\</ { $!pointy-depth++ }
					default {
						die "Unknown open balanced";
					}
				}
			}
			when Perl6::Balanced::Exit {
				given $token.content {
					when /\}/ { $!brace-depth-- }
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

	method update-indent-backward( Perl6::Element $token ) {
		given $token {
			when Perl6::Balanced::Enter {
				given $token.content {
					when /\{/ { $!brace-depth-- }
					when /\(/ { $!paren-depth-- }
					when /\[/ { $!square-depth-- }
					when /\</ { $!pointy-depth-- }
					default {
						die "Unknown open balanced";
					}
				}
			}
			when Perl6::Balanced::Exit {
				given $token.content {
					when /\}/ { $!brace-depth++ }
					when /\)/ { $!paren-depth++ }
					when /\]/ { $!square-depth++ }
					when /\>/ { $!pointy-depth++ }
					default {
						die "Unknown open balanced";
					}
				}
			}
		}
	}

	method reflow-open-brace( Int $index ) {
		given $.indent-style {
			when 'tab' | 'Ratliff' | 'Lisp' {
				self.require-ws-token-after(
					$index,
					self.spare-newline,
					self.spare-indent( $.brace-depth + 1 )
				);
				self.require-ws-token-before(
					$index, self.spare-space
				);
			}
			when 'space' {
			}
			when 'Allman' {
				self.require-ws-token-after(
					$index, self.spare-newline
				);
				self.require-ws-token-before(
					$index, self.spare-newline
				);
			}
			when 'GNU' {
				self.require-ws-token-after(
					$index, self.spare-newline
				);
				self.require-ws-token-before(
					$index,
					self.spare-newline,
					self.spare-half-tab
				);
			}
			when 'Whitesmiths' {
				self.require-ws-token-after(
					$index, self.spare-newline
				);
				self.require-ws-token-before(
					$index,
					self.spare-newline,
					self.spare-tab
				);
			}
			when 'Horstmann' | 'Pico' {
				#Nothing after, let statement indent.
				self.require-ws-token-before(
					$index, self.spare-newline
				);
			}
		}
	}

	method reflow-close-brace( Int $index ) {
		given $.indent-style {
			when 'tab' | 'Allman' | 'Horstmann' {
				self.require-ws-token-before(
					$index,
					self.spare-newline,
					self.spare-indent( $.brace-depth - 1 )
				);
			}
			when 'space' {
			}
			when 'GNU' {
				self.require-ws-token-before(
					$index,
					self.spare-newline,
					self.spare-half-tab
				);
			}
			when 'Whitesmiths' | 'Ratliff' {
				self.require-ws-token-before(
					$index,
					self.spare-newline,
					self.spare-tab
				);
			}
			when 'Horstmann' {
				self.require-ws-token-before(
					$index,
					self.spare-newline
				);
			}
			when 'Pico' | 'Lisp' {
				self.require-ws-token-before(
					$index,
					self.spare-space
				);
			}
		}
	}

	method tidy( Str $source ) {
		@!token = $.parser.to-tokens-only( $source );

		my $iterated = '';

		# Notice that we count indent levels backwards as well.
		#
		for @.token.keys.reverse -> $index {
			my $e = @.token[$index];
			self.update-indent-backward( $e );

			given $e {
				when Perl6::Pod {
					@.token.splice( $index, 1 ) if
						$.strip-pod or
						$.strip-documentation;
				}
				when Perl6::Comment {
					@.token.splice( $index, 1 ) if
						$.strip-comments or
						$.strip-documentation;
				}
				when Perl6::Balanced::Enter and
					.content eq OPEN-BRACE {
					if $.indent-style ne 'none' {
						self.reflow-open-brace(
							$index
						);
					}
				}
				when Perl6::Semicolon {
					if $.indent-style ne 'none' {
						self.require-ws-token-after(
							$index,
							self.spare-newline,
							self.spare-indent(
								$.brace-depth
							)
						);
					}
				}
				when Perl6::Balanced::Exit and
					.content eq CLOSE-BRACE {
					if $.indent-style ne 'none' {
						self.reflow-close-brace(
							$index
						);
					}
				}
			}
		}

		if $.indent-style ne 'none' {
			if @.token[0] ~~ Perl6::WS {
				@.token.splice( 0, 1 );
			}
			for @.token.keys.reverse -> $index {
				given @.token[$index] {
					when Perl6::Semicolon {
						if $index < @.token.elems and
							@.token[$index + 1] ~~
							Perl6::WS {
							@.token.splice( $index + 1, 1 );
						}
					}
				}
			}
			if @.token[*-1] ~~ Perl6::WS {
				@.token.splice( *-1, 1 );
			}
		}

		for @.token {
say "<{$_.content}>";
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
