#!/usr/bin/env perl

use strict;

use CGI;
use CouchDB::Client;
use WWW::Mechanize;
use Data::Dumper;

# >>>>>>>>>>>>>>>>>>>>>>> Database name
my $link_harvester_db_name = "db";
my $couchdb_uri = "http://127.0.0.1:5984/";
# >>>>>>>>>>>>>>>>>>>>>>> and location

my $cgi = CGI->new();

print
	$cgi->header('text/html'),
	$cgi->start_form,
	$cgi->textfield('url'),
	$cgi->submit('');

if ( $cgi->param('url') ) {
	my $mech = WWW::Mechanize -> new(agent => "NotBlocked/0.01");
	my $html;
	if ($cgi -> param('url') =~ /^http:\/\//) {
		$html = $mech -> get($cgi -> param('url')) -> content();
	} else {
		$html = $mech -> get("http://" . $cgi -> param('url')) -> content();
	}
	print $html;
	# >>>>>>>>>>>>>>>>>>>>>>> CouchDB
	my $client = CouchDB::Client -> new(uri => $couchdb_uri);
	my $db = $client -> newDB($link_harvester_db_name);
	my $doc = $db -> newDoc($cgi->param('url'), undef, {html => $html});
	$doc -> create;
	# <<<<<<<<<<<<<<<<<<<<<<< CouchDB
}
