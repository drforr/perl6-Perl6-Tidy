use v6;

use Perl6::Tidy;
use Test;

subtest 'null hypothesis', {
	my $pt = Perl6::Tidy.new;
	my ( $source, $tidied );
	$source = qq{1+ 2\t*3};
	$tidied = $pt.tidy( $source );
	is $tidied, $source, Q{null hypothesis - no changes};
};

my ( $source, $tidied );
$source = Q{1-3+ 2	*3};

subtest 'cuddled', {
	my $pt = Perl6::Tidy.new( :operator-style( 'cuddled' ) );
	my $cuddled = Q{1-3+2*3};
	$tidied = $pt.tidy( $source );
	is $tidied, $cuddled, Q{cuddling successful};
};

subtest 'uncuddled', {
	my $pt = Perl6::Tidy.new( :operator-style( 'uncuddled' ) );
	my $uncuddled = Q{1-3 + 2 * 3};
	$tidied = $pt.tidy( $source );
	is $tidied, $uncuddled, Q{uncuddling successful};
};

done-testing;

# vim: ft=perl6
