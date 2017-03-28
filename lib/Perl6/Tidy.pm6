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

    # This *will* execute phasers such as BEGIN in your existing code.
    # This may constitute a security hole, at least until the author figures
    # out how to truly make the Perl 6 grammar standalone.

=end SYNOPSIS

=begin DESCRIPTION

Uses L<Perl6::Parser> to parse your source into a Perl 6 data structure, then walks the data structure and prints it according to your format guidelines.

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
	'space'
;

subset Indent-Amount of Positive-Int;

class Perl6::Tidy {
	has Perl6::Parser $.parser = Perl6::Parser.new;

	has Bool          $.strip-comments = False;
	has Bool          $.strip-pod = False;
	has Bool          $.strip-documentation = False;

	has Indent-Style  $.indent-style = 'none';
	has Indent-Amount $.indent-amount = 1;

	has Non-Negative-Int $.brace-depth = 0;
	has Non-Negative-Int $.pointy-depth = 0;
	has Non-Negative-Int $.square-depth = 0;
	has Non-Negative-Int $.paren-depth = 0;

	method debug-indent {
		"\{: $.brace-depth; " ~
		"\<: $.pointy-depth; " ~
		"\[: $.square-depth; " ~
		"\(: $.paren-depth;";
	}

	# Use REs to match the braces because ':(..)' is valid.
	#
	method update-indent( Perl6::Element $token ) {
		return unless $token ~~ Perl6::Balanced;

		if $token ~~ Perl6::Balanced::Enter {
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
		elsif $token ~~ Perl6::Balanced::Exit {
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
		else {
			die "Unknown balanced";
		}
	}

	method indent-string( Int $depth ) {
		my $string = '';
		given $.indent-style {
			when 'tab' {
				$string = "\t" x $depth;
			}
			when 'space' {
				$string = " " x $depth;
			}
		}
		$string;
	}

	method skip-token( Perl6::Element $e ) {
		return True if $.strip-documentation and
			$e ~~ Perl6::Pod | Perl6::Comment;
		return True if $.strip-pod and
			$e ~~ Perl6::Pod;
		return True if $.strip-comments and
			$e ~~ Perl6::Comment;
		return False;
	}

	method token-to-string( Perl6::Element $e ) {
		my $depth = $.brace-depth + $.paren-depth;
		return '' if self.skip-token( $e );

		return $e.content if $.indent-style eq 'none';

		given $e {
			when Perl6::WS {
				if .next-leaf ~~ Perl6::Balanced::Exit and
					.next-leaf.content eq '}' | ')' {
					return self.indent-string( $depth - 1 );
				}
				if .previous-leaf ~~ Perl6::Newline {
					return self.indent-string( $depth );
				}
			}
			default {
				if .previous-leaf ~~ Perl6::Newline {
					return self.indent-string( $depth ) ~
						.content;
				}
			}
		}
		return $e.content;
	}

	method tidy( Str $source ) {
		my @token = $.parser.to-list( $source );
		my $iterated = '';
		for grep { .textual }, @token {
			self.update-indent( $_ );
			$iterated ~= self.token-to-string( $_ );
		}
		$iterated;
	}
}
