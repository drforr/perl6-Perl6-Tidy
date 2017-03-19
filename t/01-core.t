use v6;

use Test;
use Perl6::Tidy;

plan 3;

subtest {
	plan 1;
	
	my $pt = Perl6::Tidy.new;
	my $source = Q{1+2};
	my $parsed = $pt.tidy( $source );
	is $parsed, $source, Q{No alterations};
}, Q{No alterations};

subtest {
	plan 1;
	
	my $pt = Perl6::Tidy.new;
	my $source = Q{1+2 # foo};
	my $parsed = $pt.tidy( $source );
	is $parsed, $source, Q{No alterations};
}, Q{Comment};

subtest {
	plan 1;
	
	my $pt = Perl6::Tidy.new( :strip-comments( True ) );
	my $source = Q{1+2 # foo};
	my $tidied = Q{1+2 };
	my $parsed = $pt.tidy( $source );
	is $parsed, $tidied, Q{No alterations};
}, Q{Comment};

# vim: ft=perl6
