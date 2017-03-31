use v6;

use Test;
use Perl6::Tidy;

plan 8;

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'tab' ) );
	my ( $source, $tidied );
	subtest {
		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
}
END
			subtest {
				$source = Q{sub a{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{no spaces};

				$source = Q{sub a {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{space between foo and brace};

				$source = qq{sub a\n{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{newline between foo and brace};

				$source = qq{sub a \n {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{mixed spaces between foo and brace};
			}, Q{no space inside brace};

			subtest {
				$source = Q{sub a{ }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{single space};

				$source = qq{sub a{ \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces};
			}, Q{whitespace inside brace};

			done-testing;
		}, Q{no block content};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	'foo'
}
END
			$source = Q{sub a{'foo'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with no semicolons};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	'foo';
}
END
			$source = Q{sub a{'foo';}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with trailing semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	'foo';
}
END
			$source = Q{sub a{ 'foo' ; }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{single statement with space before trailing semicolon};

		subtest {
			# Show that ';' inside array dimensions is not affected
			my $tabbed = chomp Q:to[END];
sub a {
	'foo'[1;1];
	'bar'
}
END
			$source = Q{sub a{ 'foo'[1;1] ; 'bar' }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo'[1;1] \n ; \n 'bar' \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	'foo';
	'bar';
}
END
			$source = Q{sub a{ 'foo' ; 'bar' ;}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	'foo';
	'bar';
	'baz'
}
END
			$source = Q{sub a{ 'foo' ; 'bar' ; 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source =
				qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{three statements, no trailing semi};

		done-testing;
	}, Q{format single block};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a {
}
sub b {
}
END
		subtest {
			$source = qq{sub a{}\nsub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {}\nsub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{}\nsub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}\n \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks in a row, no semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a {
};
sub b {
}
END
		subtest {
			$source = qq{sub a{};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks with semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a {
	sub c {
	}
};
sub b {
}
END
		subtest {
			$source = qq{sub a{sub c{}};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {sub c{}};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{sub c{}};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {sub c{}}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{nested bare block};

	done-testing;
}, Q{1tbs};

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'Allman' ) );
	my ( $source, $tidied );
	subtest {
		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{
}
END
			subtest {
				$source = Q{sub a{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{no spaces};

				$source = Q{sub a {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{space between foo and brace};

				$source = qq{sub a\n{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{newline between foo and brace};

				$source = qq{sub a \n {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{mixed spaces between foo and brace};
			}, Q{no space inside brace};

			subtest {
				$source = Q{sub a{ }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{single space};

				$source = qq{sub a{ \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces};
			}, Q{whitespace inside brace};

			done-testing;
		}, Q{no block content};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{
	'foo'
}
END
			$source = Q{sub a{'foo'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with no semicolons};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{
	'foo';
}
END
			$source = Q{sub a{'foo';}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with trailing semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{
	'foo';
}
END
			$source = Q{sub a{ 'foo' ; }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{single statement with space before trailing semicolon};

		subtest {
			# Show that ';' inside array dimensions is not affected
			my $tabbed = chomp Q:to[END];
sub a
{
	'foo'[1;1];
	'bar'
}
END
			$source = Q{sub a{ 'foo'[1;1] ; 'bar' }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo'[1;1] \n ; \n 'bar' \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{
	'foo';
	'bar';
}
END
			$source = Q{sub a{ 'foo' ; 'bar' ;}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{
	'foo';
	'bar';
	'baz'
}
END
			$source = Q{sub a{ 'foo' ; 'bar' ; 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source =
				qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{three statements, no trailing semi};

		done-testing;
	}, Q{format single block};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a
{
}
sub b
{
}
END
		subtest {
			$source = qq{sub a{}\nsub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {}\nsub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{}\nsub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}\n \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks in a row, no semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a
{
};
sub b
{
}
END
		subtest {
			$source = qq{sub a{};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks with semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a
{
	sub c
	{
	}
};
sub b
{
}
END
		subtest {
			$source = qq{sub a{sub c{}};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {sub c{}};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{sub c{}};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {sub c{}}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{nested bare block};

	done-testing;
}, Q{Allman};

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'GNU' ) );
	my ( $source, $tidied );
	subtest {
		subtest {
			my $tabbed = chomp Q:to[END];
sub a
    {
    }
END
			subtest {
				$source = Q{sub a{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{no spaces};

				$source = Q{sub a {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{space between foo and brace};

				$source = qq{sub a\n{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{newline between foo and brace};

				$source = qq{sub a \n {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{mixed spaces between foo and brace};
			}, Q{no space inside brace};

			subtest {
				$source = Q{sub a{ }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{single space};

				$source = qq{sub a{ \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces};
			}, Q{whitespace inside brace};

			done-testing;
		}, Q{no block content};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
    {
	'foo'
    }
END
			$source = Q{sub a{'foo'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with no semicolons};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
    {
	'foo';
    }
END
			$source = Q{sub a{'foo';}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with trailing semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
    {
	'foo';
    }
END
			$source = Q{sub a{ 'foo' ; }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{single statement with space before trailing semicolon};

		subtest {
			# Show that ';' inside array dimensions is not affected
			my $tabbed = chomp Q:to[END];
sub a
    {
	'foo'[1;1];
	'bar'
    }
END
			$source = Q{sub a{ 'foo'[1;1] ; 'bar' }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo'[1;1] \n ; \n 'bar' \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
    {
	'foo';
	'bar';
    }
END
			$source = Q{sub a{ 'foo' ; 'bar' ;}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
    {
	'foo';
	'bar';
	'baz'
    }
END
			$source = Q{sub a{ 'foo' ; 'bar' ; 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source =
				qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{three statements, no trailing semi};

		done-testing;
	}, Q{format single block};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a
    {
    }
sub b
    {
    }
END
		subtest {
			$source = qq{sub a{}\nsub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {}\nsub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{}\nsub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}\n \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks in a row, no semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a
    {
    };
sub b
    {
    }
END
		subtest {
			$source = qq{sub a{};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks with semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a
    {
	sub c
	    {
	    }
    };
sub b
    {
    }
END
		subtest {
			$source = qq{sub a{sub c{}};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {sub c{}};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{sub c{}};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {sub c{}}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{nested bare block};

	done-testing;
}, Q{GNU};

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'Whitesmiths' ) );
	my ( $source, $tidied );
	subtest {
		subtest {
			my $tabbed = chomp Q:to[END];
sub a
	{
	}
END
			subtest {
				$source = Q{sub a{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{no spaces};

				$source = Q{sub a {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{space between foo and brace};

				$source = qq{sub a\n{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{newline between foo and brace};

				$source = qq{sub a \n {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{mixed spaces between foo and brace};
			}, Q{no space inside brace};

			subtest {
				$source = Q{sub a{ }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{single space};

				$source = qq{sub a{ \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces};
			}, Q{whitespace inside brace};

			done-testing;
		}, Q{no block content};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
	{
	'foo'
	}
END
			$source = Q{sub a{'foo'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with no semicolons};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
	{
	'foo';
	}
END
			$source = Q{sub a{'foo';}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with trailing semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
	{
	'foo';
	}
END
			$source = Q{sub a{ 'foo' ; }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{single statement with space before trailing semicolon};

		subtest {
			# Show that ';' inside array dimensions is not affected
			my $tabbed = chomp Q:to[END];
sub a
	{
	'foo'[1;1];
	'bar'
	}
END
			$source = Q{sub a{ 'foo'[1;1] ; 'bar' }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo'[1;1] \n ; \n 'bar' \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
	{
	'foo';
	'bar';
	}
END
			$source = Q{sub a{ 'foo' ; 'bar' ;}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
	{
	'foo';
	'bar';
	'baz'
	}
END
			$source = Q{sub a{ 'foo' ; 'bar' ; 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source =
				qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{three statements, no trailing semi};

		done-testing;
	}, Q{format single block};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a
	{
	}
sub b
	{
	}
END
		subtest {
			$source = qq{sub a{}\nsub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {}\nsub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{}\nsub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}\n \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks in a row, no semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a
	{
	};
sub b
	{
	}
END
		subtest {
			$source = qq{sub a{};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks with semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a
	{
	sub c
		{
		}
	};
sub b
	{
	}
END
		subtest {
			$source = qq{sub a{sub c{}};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {sub c{}};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{sub c{}};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {sub c{}}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{nested bare block};

	done-testing;
}, Q{Whitesmiths};

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'Horstmann' ) );
	my ( $source, $tidied );
	subtest {
		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{
}
END
			subtest {
				$source = Q{sub a{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{no spaces};

				$source = Q{sub a {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{space between foo and brace};

				$source = qq{sub a\n{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{newline between foo and brace};

				$source = qq{sub a \n {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{mixed spaces between foo and brace};
			}, Q{no space inside brace};

			subtest {
				$source = Q{sub a{ }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{single space};

				$source = qq{sub a{ \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces};
			}, Q{whitespace inside brace};

			done-testing;
		}, Q{no block content};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{	'foo'
}
END
			$source = Q{sub a{'foo'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with no semicolons};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{	'foo';
}
END
			$source = Q{sub a{'foo';}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with trailing semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{	'foo';
}
END
			$source = Q{sub a{ 'foo' ; }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{single statement with space before trailing semicolon};

		subtest {
			# Show that ';' inside array dimensions is not affected
			my $tabbed = chomp Q:to[END];
sub a
{	'foo'[1;1];
	'bar'
}
END
			$source = Q{sub a{ 'foo'[1;1] ; 'bar' }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo'[1;1] \n ; \n 'bar' \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{	'foo';
	'bar';
}
END
			$source = Q{sub a{ 'foo' ; 'bar' ;}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{	'foo';
	'bar';
	'baz'
}
END
			$source = Q{sub a{ 'foo' ; 'bar' ; 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source =
				qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{three statements, no trailing semi};

		done-testing;
	}, Q{format single block};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a
{
}
sub b
{
}
END
		subtest {
			$source = qq{sub a{}\nsub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {}\nsub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{}\nsub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}\n \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks in a row, no semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a
{
};
sub b
{
}
END
		subtest {
			$source = qq{sub a{};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks with semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a
{	sub c
	{
	}
};
sub b
{
}
END
		subtest {
			$source = qq{sub a{sub c{}};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {sub c{}};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{sub c{}};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {sub c{}}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{nested bare block};

	done-testing;
}, Q{Horstmann};

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'Pico' ) );
	my ( $source, $tidied );
	subtest {
		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{ }
END
			subtest {
				$source = Q{sub a{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{no spaces};

				$source = Q{sub a {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{space between foo and brace};

				$source = qq{sub a\n{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{newline between foo and brace};

				$source = qq{sub a \n {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{mixed spaces between foo and brace};
			}, Q{no space inside brace};

			subtest {
				$source = Q{sub a{ }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{single space};

				$source = qq{sub a{ \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces};
			}, Q{whitespace inside brace};

			done-testing;
		}, Q{no block content};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{	'foo' }
END
			$source = Q{sub a{'foo'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with no semicolons};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{	'foo'; }
END
			$source = Q{sub a{'foo';}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with trailing semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{	'foo'; }
END
			$source = Q{sub a{ 'foo' ; }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{single statement with space before trailing semicolon};

		subtest {
			# Show that ';' inside array dimensions is not affected
			my $tabbed = chomp Q:to[END];
sub a
{	'foo'[1;1];
	'bar' }
END
			$source = Q{sub a{ 'foo'[1;1] ; 'bar' }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo'[1;1] \n ; \n 'bar' \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{	'foo';
	'bar'; }
END
			$source = Q{sub a{ 'foo' ; 'bar' ;}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a
{	'foo';
	'bar';
	'baz' }
END
			$source = Q{sub a{ 'foo' ; 'bar' ; 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source =
				qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{three statements, no trailing semi};

		done-testing;
	}, Q{format single block};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a
{ }
sub b
{ }
END
		subtest {
			$source = qq{sub a{}\nsub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {}\nsub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{}\nsub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}\n \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks in a row, no semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a
{ };
sub b
{ }
END
		subtest {
			$source = qq{sub a{};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks with semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a
{	sub c
	{ } };
sub b
{ }
END
		subtest {
			$source = qq{sub a{sub c{}};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {sub c{}};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{sub c{}};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {sub c{}}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{nested bare block};

	done-testing;
}, Q{Pico};

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'Ratliff' ) );
	my ( $source, $tidied );
	subtest {
		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	}
END
			subtest {
				$source = Q{sub a{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{no spaces};

				$source = Q{sub a {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{space between foo and brace};

				$source = qq{sub a\n{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{newline between foo and brace};

				$source = qq{sub a \n {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{mixed spaces between foo and brace};
			}, Q{no space inside brace};

			subtest {
				$source = Q{sub a{ }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{single space};

				$source = qq{sub a{ \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces};
			}, Q{whitespace inside brace};

			done-testing;
		}, Q{no block content};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	'foo'
	}
END
			$source = Q{sub a{'foo'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with no semicolons};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	'foo';
	}
END
			$source = Q{sub a{'foo';}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with trailing semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	'foo';
	}
END
			$source = Q{sub a{ 'foo' ; }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{single statement with space before trailing semicolon};

		subtest {
			# Show that ';' inside array dimensions is not affected
			my $tabbed = chomp Q:to[END];
sub a {
	'foo'[1;1];
	'bar'
	}
END
			$source = Q{sub a{ 'foo'[1;1] ; 'bar' }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo'[1;1] \n ; \n 'bar' \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	'foo';
	'bar';
	}
END
			$source = Q{sub a{ 'foo' ; 'bar' ;}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	'foo';
	'bar';
	'baz'
	}
END
			$source = Q{sub a{ 'foo' ; 'bar' ; 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source =
				qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{three statements, no trailing semi};

		done-testing;
	}, Q{format single block};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a {
	}
sub b {
	}
END
		subtest {
			$source = qq{sub a{}\nsub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {}\nsub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{}\nsub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}\n \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks in a row, no semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a {
	};
sub b {
	}
END
		subtest {
			$source = qq{sub a{};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks with semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a {
	sub c {
		}
	};
sub b {
	}
END
		subtest {
			$source = qq{sub a{sub c{}};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {sub c{}};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{sub c{}};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {sub c{}}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{nested bare block};

	done-testing;
}, Q{Ratliff};

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'Lisp' ) );
	my ( $source, $tidied );
	subtest {
		subtest {
			my $tabbed = chomp Q:to[END];
sub a { }
END
			subtest {
				$source = Q{sub a{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{no spaces};

				$source = Q{sub a {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{space between foo and brace};

				$source = qq{sub a\n{}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{newline between foo and brace};

				$source = qq{sub a \n {}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed,
					Q{mixed spaces between foo and brace};
			}, Q{no space inside brace};

			subtest {
				$source = Q{sub a{ }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{single space};

				$source = qq{sub a{ \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces};
			}, Q{whitespace inside brace};

			done-testing;
		}, Q{no block content};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	'foo' }
END
			$source = Q{sub a{'foo'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo' }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo' \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with no semicolons};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	'foo'; }
END
			$source = Q{sub a{'foo';}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no whitespace};

			subtest {
				$source = Q{sub a{ 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo';}};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{start only};

			subtest {
				$source = Q{sub a{'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{end only};

			subtest {
				$source = Q{sub a{ 'foo'; }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{space at start};

				$source = qq{sub a{ \n 'foo'; \n }};
				$tidied = $pt.tidy( $source );
				is $tidied, $tabbed, Q{mixed spaces at start};

				done-testing;
			}, Q{mixed};

			done-testing;
		}, Q{single statement with trailing semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	'foo'; }
END
			$source = Q{sub a{ 'foo' ; }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{single statement with space before trailing semicolon};

		subtest {
			# Show that ';' inside array dimensions is not affected
			my $tabbed = chomp Q:to[END];
sub a {
	'foo'[1;1];
	'bar' }
END
			$source = Q{sub a{ 'foo'[1;1] ; 'bar' }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo'[1;1] \n ; \n 'bar' \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	'foo';
	'bar'; }
END
			$source = Q{sub a{ 'foo' ; 'bar' ;}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source = qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n }};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{two statements with splitting semicolon};

		subtest {
			my $tabbed = chomp Q:to[END];
sub a {
	'foo';
	'bar';
	'baz' }
END
			$source = Q{sub a{ 'foo' ; 'bar' ; 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space at start};

			$source =
				qq{sub a{ \n 'foo' \n ; \n 'bar' \n ; \n 'baz'}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{mixed spaces at start};

			done-testing;
		}, Q{three statements, no trailing semi};

		done-testing;
	}, Q{format single block};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a { }
sub b { }
END
		subtest {
			$source = qq{sub a{}\nsub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {}\nsub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{}\nsub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}\n \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks in a row, no semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a { };
sub b { }
END
		subtest {
			$source = qq{sub a{};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{two blocks with semicolon};

	subtest {
		my $tabbed = chomp Q:to[END];
sub a {
	sub c { } };
sub b { }
END
		subtest {
			$source = qq{sub a{sub c{}};sub b{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{no spaces};

			$source = qq{sub a {sub c{}};sub b {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{space between foo and brace};

			$source = qq{sub a\n{sub c{}};sub b\n{}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed, Q{newline between foo and brace};

			$source = qq{sub a \n {sub c{}}; \n sub b \n {}};
			$tidied = $pt.tidy( $source );
			is $tidied, $tabbed,
				Q{mixed spaces between foo and brace};

			done-testing;
		}, Q{no space inside brace};

		done-testing;
	}, Q{nested bare block};

	done-testing;
}, Q{Lisp};

# vim: ft=perl6
