#!/usr/bin/env perl
use common::sense;
use Mojo::UserAgent;
use Data::Dumper;

my $ua = Mojo::UserAgent->new;


my %hash = (
	redirect_uri => 'https://developers.google.com/oauthplayground',
	scope =>  'https://www.googleapis.com/auth/calendar',
	response_type =>  'code',
	client_id => '397141148797-hnbm3cl49buonecqa982iamefll5bpn9.apps.googleusercontent.com',
	approval_prompt => 'force',
	access_type => 'offline'
);

warn Dumper $ua->get('https://accounts.google.com/o/oauth2/auth' => form => \%hash)->res->code;


# https://accounts.google.com/o/oauth2/auth?
# redirect_uri=https://developers.google.com/oauthplayground&
# response_type=code&
# client_id=397141148797-hnbm3cl49buonecqa982iamefll5bpn9.apps.googleusercontent.com&
# scope=https://www.googleapis.com/auth/calendar&
# approval_prompt=force&access_type=offline