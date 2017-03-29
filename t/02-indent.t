use v6;

use Test;
use Perl6::Tidy;

plan 1;

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'tab' ) );
	my $tabbed = chomp Q:to[END];
sub foo {
	sub bar {
		'a'
	};
	sub baz {
		'c';
		'd';
	}
}
END
	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a'};sub baz{'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{No whitespace to start};

#`(
	subtest {
		plan 1;
	
		my $source = Q{ sub foo{ sub bar{ 'a'} ;sub baz{ 'c'; 'd';} } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Leading whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a' };sub baz{'c'; 'd'; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Trailing whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo {sub bar {'a'};sub baz {'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Before open brace};

	subtest {
		plan 1;
	
		my $source = Q{ sub foo { sub bar { 'a' } ; sub baz { 'c' ; 'd' ; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Whitespace everywhere};
)
}, Q{Basic tab style};

#`(

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'tab' ) );
	my $tabbed = Q:to[END];
sub foo
{
	sub bar
	{
		'a'
	};
	sub baz
	{
		'c';
		'd';
	}
}
END
	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a'};sub baz{'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{No whitespace to start};

	subtest {
		plan 1;
	
		my $source = Q{ sub foo{ sub bar{ 'a'} ;sub baz{ 'c'; 'd';} } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Leading whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a' };sub baz{'c'; 'd'; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Trailing whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo {sub bar {'a'};sub baz {'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Before open brace};

	subtest {
		plan 1;
	
		my $source = Q{ sub foo { sub bar { 'a' } ; sub baz { 'c' ; 'd' ; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Whitespace everywhere};
}, Q{Allman tab style};

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'tab' ) );
	my $tabbed = Q:to[END];
sub foo
    {
	sub bar
	    {
		'a'
	    };
	sub baz
	    {
		'c';
		'd';
	    }
    }
END
	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a'};sub baz{'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{No whitespace to start};

	subtest {
		plan 1;
	
		my $source = Q{ sub foo{ sub bar{ 'a'} ;sub baz{ 'c'; 'd';} } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Leading whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a' };sub baz{'c'; 'd'; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Trailing whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo {sub bar {'a'};sub baz {'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Before open brace};

	subtest {
		plan 1;
	
		my $source = Q{ sub foo { sub bar { 'a' } ; sub baz { 'c' ; 'd' ; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Whitespace everywhere};
}, Q{GNU tab style};

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'tab' ) );
	my $tabbed = Q:to[END];
sub foo
	{
	sub bar
		{
		'a'
		};
	sub baz
		{
		'c';
		'd';
		}
	}
END
	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a'};sub baz{'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{No whitespace to start};

	subtest {
		plan 1;
	
		my $source = Q{ sub foo{ sub bar{ 'a'} ;sub baz{ 'c'; 'd';} } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Leading whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a' };sub baz{'c'; 'd'; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Trailing whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo {sub bar {'a'};sub baz {'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Before open brace};

	subtest {
		plan 1;
	
		my $source = Q{ sub foo { sub bar { 'a' } ; sub baz { 'c' ; 'd' ; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Whitespace everywhere};
}, Q{Whitesmiths tab style};

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'tab' ) );
	my $tabbed = Q:to[END];
sub foo
{	sub bar
	{	'a'
	};
	sub baz
	{	'c';
		'd';
	}
}
END
	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a'};sub baz{'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{No whitespace to start};

	subtest {
		plan 1;
	
		my $source = Q{ sub foo{ sub bar{ 'a'} ;sub baz{ 'c'; 'd';} } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Leading whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a' };sub baz{'c'; 'd'; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Trailing whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo {sub bar {'a'};sub baz {'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Before open brace};

	subtest {
		plan 1;
	
		my $source = Q{ sub foo { sub bar { 'a' } ; sub baz { 'c' ; 'd' ; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Whitespace everywhere};
}, Q{Horstmann tab style};

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'tab' ) );
	my $tabbed = Q:to[END];
sub foo
{	sub bar
	{	'a' };
	sub baz
	{	'c';
		'd'; } }
END
	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a'};sub baz{'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{No whitespace to start};

	subtest {
		plan 1;
	
		my $source = Q{ sub foo{ sub bar{ 'a'} ;sub baz{ 'c'; 'd';} } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Leading whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a' };sub baz{'c'; 'd'; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Trailing whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo {sub bar {'a'};sub baz {'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Before open brace};

	subtest {
		plan 1;
	
		my $source = Q{ sub foo { sub bar { 'a' } ; sub baz { 'c' ; 'd' ; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Whitespace everywhere};
}, Q{Pico tab style};

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'tab' ) );
	my $tabbed = Q:to[END];
sub foo {
	sub bar {
		'a'
		};
	sub baz {
		'c';
		'd';
		}
	}
END
	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a'};sub baz{'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{No whitespace to start};

	subtest {
		plan 1;
	
		my $source = Q{ sub foo{ sub bar{ 'a'} ;sub baz{ 'c'; 'd';} } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Leading whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a' };sub baz{'c'; 'd'; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Trailing whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo {sub bar {'a'};sub baz {'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Before open brace};

	subtest {
		plan 1;
	
		my $source = Q{ sub foo { sub bar { 'a' } ; sub baz { 'c' ; 'd' ; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Whitespace everywhere};
}, Q{Ratliff tab style};

subtest {
	my $pt = Perl6::Tidy.new( :indent-style( 'tab' ) );
	my $tabbed = Q:to[END];
sub foo {
	sub bar {
		'a' };
	sub baz {
		'c';
		'd'; } }
END
	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a'};sub baz{'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{No whitespace to start};

	subtest {
		plan 1;
	
		my $source = Q{ sub foo{ sub bar{ 'a'} ;sub baz{ 'c'; 'd';} } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Leading whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo{sub bar{'a' };sub baz{'c'; 'd'; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Trailing whitespace};

	subtest {
		plan 1;
	
		my $source = Q{sub foo {sub bar {'a'};sub baz {'c';'d';}}};
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Before open brace};

	subtest {
		plan 1;
	
		my $source = Q{ sub foo { sub bar { 'a' } ; sub baz { 'c' ; 'd' ; } } };
		my $tidied = $pt.tidy( $source );
		is $tidied, $tabbed, Q{No alterations};
	}, Q{Whitespace everywhere};
}, Q{Lisp tab style};

)

# vim: ft=perl6
