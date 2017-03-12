=begin pod

=begin NAME

Perl6::Tidy - Tidy Perl 6 source code according to your guidelines

=end NAME

=begin SYNOPSIS

    my $pt = Perl6::Tidy.new(
        :strip-comments( False ), # No change, just to be clear.
    );
    my $tidied = $pt.tidy( Q:to[_END_] );
       code-goes-here();
       that you( $want-to, $parse );
    _END_
    say $tidied;

    # This *will* execute phasers such as BEGIN in your existing code.
    # This may constitute a security hole, at least until the author figures
    # out how to truly make the Perl 6 grammar standalone.

=end SYNOPSIS

=begin DESCRIPTION

Uses L<Perl6::Parser> to parse your source into a Perl 6 data structure, then walks the data structure and prints it according to your format guidelines.

=end DESCRIPTION

=begin METHODS

=end METHODS

=end pod

use Perl6::Parser;

my role Debugging {
}

my role Testing {
}

my role Validating {
}

class Perl6::Tidy {
	also does Debugging;
	also does Testing;
	also does Validating;

	has Perl6::Parser $.parser = Perl6::Parser.new;

	has Bool $.strip-comments = False;

	method tidy( Str $source ) {
		my $iter = $.parser.iterator( $source );
		my $iterated = '';
		for Seq.new( $iter ) {
			next if $.strip-comments and $_ ~~ Perl6::Comment;
			$iterated ~= $_.is-leaf ?? $_.content !! '';
		}
		$iterated;
	}
}
