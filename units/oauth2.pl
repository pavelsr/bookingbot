#!/usr/bin/env perl

use strict;
use warnings;

use lib '/home/denver/perl5/lib/perl5';

use JSON qw(encode_json);
use MIME::Base64::URLSafe qw(urlsafe_b64encode);
use Crypt::JWT qw(encode_jwt);
use LWP::UserAgent;

use Data::Dumper;

sub get_calendarList {
  my $access_token = shift;
  my $url = 'https://www.googleapis.com/calendar/v3/users/me/calendarList';

  my $ua = LWP::UserAgent->new;

  my $req = HTTP::Request->new(GET => $url);

  $req->header('Authorization' => 'Bearer ' . $access_token);

  my $resp = $ua->request($req);
  print $resp->as_string();
}

sub read_oauth2data {
  my $filename = 'oauth2data.json';
  my $json_text = do {
    open (my $json_fh, '<:encoding(UTF-8)', $filename)
      or die("Can't open \$filename\": $!\n");
    local $/;
    <$json_fh>
  };

  my $json = JSON->new;
  return $json->decode($json_text);
}
my $oauth2data = read_oauth2data;

my $url = 'https://www.googleapis.com/oauth2/v4/token';

my $now = time;
my $payload = {
  'iss' => $oauth2data->{client_email},
  'sub' => 'fablab61ru@gmail.com',
  'scope' => 'https://www.googleapis.com/auth/calendar',
  'aud' => $url,
  'iat' => $now,
  'exp' => $now + 3600
};

my $buffer = $oauth2data->{private_key};
my $pk = Crypt::PK::RSA->new(\$buffer);

my $const_assertion = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=';
my $assertion = encode_jwt(payload => $payload, alg => 'RS256', key => $pk);

my $ua = LWP::UserAgent->new(); 
my $req = HTTP::Request->new(POST => $url);
$req->header('Content-Type' => 'application/x-www-form-urlencoded');
$req->content($const_assertion . $assertion);

my $resp = $ua->request($req);
print $resp->as_string();

if ($resp->is_success) {
  my $json = JSON->new;
  my $response = $json->decode($resp->decoded_content);
  my $access_token = $response->{access_token};
  get_calendarList($access_token)
}
