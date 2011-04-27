#
#
use strict;
use warnings;
use Test::More;
BEGIN {
	eval 'use AnyEvent';
	plan skip_all => "AnyEvent is required for this test" if $@;
}
plan tests => 18;
use Net::Curl::Simple;
use Net::Curl::Simple::Async qw(AnyEvent);

my $got = 0;
Net::Curl::Simple->new->get( "http://google.com/", sub {
	my $curl = shift;
	my $result = shift;
	$got = 1;

	ok( defined $result, 'finish callback called' );
	cmp_ok( $result, '==', 0, 'downloaded successfully' );
	ok( ! $curl->{in_use}, 'handle released' );
	is( ref $curl->{headers}, 'ARRAY', 'got array of headers' );
	is( ref $curl->{body}, '', 'got body scalar' );
	cmp_ok( scalar @{ $curl->{headers} }, '>', 3, 'got at least 3 headers' );
	cmp_ok( length $curl->{body}, '>', 1000, 'got some body' );
	isnt( $curl->{referer}, '', 'referer updarted' );

	$curl->get( '/search?q=perl', \&finish2 );
} );

sub finish2
{
	my $curl = shift;
	my $result = shift;

	$got = 2;

	ok( defined $result, 'finish callback called' );
	cmp_ok( $result, '==', 0, 'downloaded successfully' );
	ok( ! $curl->{in_use}, 'handle released' );
	is( ref $curl->{headers}, 'ARRAY', 'got array of headers' );
	is( ref $curl->{body}, '', 'got body scalar' );
	cmp_ok( scalar @{ $curl->{headers} }, '>', 3, 'got at least 3 headers' );
	cmp_ok( length $curl->{body}, '>', 1000, 'got some body' );
	isnt( $curl->{referer}, '', 'referer updarted' );
}

is( $got, 0, 'request did not block' );

Net::Curl::Simple::Async::loop();

is( $got, 2, 'performed both requests' );
