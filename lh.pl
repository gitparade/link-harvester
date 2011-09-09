#!/usr/bin/env perl

use strict;
use utf8;
use open ':encoding(utf8)';
binmode(STDOUT, ":utf8");

use CGI qw/:standard :html4/;
use CouchDB::Client;
use WWW::Mechanize;
use Data::Dumper;
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

if ( $cgi->param('url') ) {
	my $mech = WWW::Mechanize -> new(agent => "NotBlocked/0.01");
	my $http;
	if ($cgi -> param('url') =~ /^http:\/\//) {
		$http = $cgi -> param('url');
	} else {
		$http = "http://" . $cgi -> param('url');
	}
	my $html = $mech -> get($http) -> decoded_content;
	my $text = $mech -> text();
	&display($text);
	# >>>>>>>>>>>>>>>>>>>>>>> CouchDB
	my $client = CouchDB::Client -> new(uri => $couchdb_uri);
	my $db = $client -> newDB($link_harvester_db_name);
	my $doc = $db -> newDoc($http, undef, {html => $html});
	$doc -> create;
	# <<<<<<<<<<<<<<<<<<<<<<< CouchDB
}

sub display {
	foreach (1..50) {
		printf "<div style='font-size : xx-large; z-index : 0; position : absolute; left : %s;'>", $_;
		print $_[0];
		print "</div>";
	}
}
