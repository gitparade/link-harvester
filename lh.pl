#!/usr/bin/env perl

use strict;
use utf8;
use open ':encoding(utf8)';
binmode(STDOUT, ":utf8");

use CGI qw/:standard :html4/;
use CouchDB::Client;
use WWW::Mechanize;
$CGI::DISABLE_UPLOADS = 1;

# >>>>>>>>>>>>>>>>>>>>>>> Database name
my $link_harvester_db_name = "db";
my $couchdb_uri = "http://127.0.0.1:5984/";
# >>>>>>>>>>>>>>>>>>>>>>> and location

my $cgi = CGI->new();

print
	$cgi->header(-charset=>'utf-8'),
	"<div style='z-index : 1; position : fixed; top : 0; left : 0;'>",
	$cgi->start_form,
	$cgi->textfield('url'),
	$cgi->submit(''),
	"</div>";

if ($cgi -> param('url')) {
	(my $text, my $http, my $html) = &www_mechanize($cgi -> param('url'));
	&write_text_to_browser($text);
	# >>>>>>>>>>>>>>>>>>>>>>> Create CouchDB document
	&key_is_url_field_is_html($http, $html);
	# <<<<<<<<<<<<<<<<<<<<<<< with url and html
}

sub key_is_url_field_is_html {
	my $client = CouchDB::Client -> new(uri => $couchdb_uri);
	my $db = $client -> newDB($link_harvester_db_name);
	my $doc = $db -> newDoc($_[0], undef, {html => $_[1]});
	$doc -> create;
}

sub write_text_to_browser {
	my $repeat = int(rand(3)) + 1;
	foreach (1..50) {
		if ($repeat == 1) {
			printf "<div style='font-size : xx-large; z-index : 0; position : absolute; left : %s;'>", $_;
		} elsif ($repeat == 2) {
			printf "<div style='font-size : xx-large; z-index : 0; position : absolute; top : %s;'>", $_;
		} elsif ($repeat == 3) {
			printf "<div style='font-size : xx-large; z-index : 0; position : absolute; top : %s; left : %s'>", $_, $_;
		}
		print $_[0];
		print "</div>";
	}
}

sub www_mechanize {
	my $mech = WWW::Mechanize -> new(agent => "NotBlocked/0.01");
	my $http;
	if ($_[0] =~ /^http:\/\//) {
		$http = $_[0];
	} else {
		$http = "http://" . $_[0];
	}
	my $html = $mech -> get($http) -> decoded_content;
	my $text = $mech -> text();
	($text, $http, $html);
}
