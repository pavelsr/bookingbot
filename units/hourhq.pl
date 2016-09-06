#!/usr/bin/env perl
use common::sense;
use Mojo::UserAgent;
use Data::Dumper;

my $ua = Mojo::UserAgent->new;
my $login = 'fablab61ru@gmail.com';

# my $res = $ua->post('https://api.timekit.io/v2/auth' => json => {
# 	'email' => $login,
# 	'password' => 'fab11boston'
# })->res->json;

# warn Dumper $res;

# $res->{data}{api_token}

# 'email' : 'fablab61ru@gmail.com',
# 'password' : 'fab11boston'

# new booking
my $hash = {};
$hash->{graph} = "confirm_decline";
$hash->{action} = "create";
$hash->{event} = {
		"start" => "2016-09-03T20:00:00+03:00",
		"end" => "2016-09-03T21:00:00+03:00",
		"what" => "Lasersaur display name x PAVEL SERIKOV",
		"where" => "website/telegram",
		"description" => "Comment: test API\nPhone number: 9885851900\n",
		"calendar_id" => "ec5780c7-56c8-40a9-a321-2ea39045f68c",
};
$hash->{customer} = {
			"name" => "IVAN IVANOV",
			"email" => "pavel.p.serikov\@gmail.com",
			"timezone" => "Europe/Moscow",
			"phone" => "9885851900"
};
#$hash->{'Timekit-App'} = 'docs';

# $hash = {
#   "graph" => "confirm_decline",
#   "action" => "create",
#   "event" => {
# 		"start" => "2016-09-03T20:00:00+03:00",
# 		"end" => "2016-09-03T21:00:00+03:00",
# 		"what" => "Lasersaur display name x PAVEL SERIKOV",
# 		"where" => "website/telegram",
# 		"description" => "Comment: test API\nPhone number: 9885851900\n",
# 		"calendar_id" => "ec5780c7-56c8-40a9-a321-2ea39045f68c",
# 	},
# 	"customer" => {
# 			"name" => "IVAN IVANOV",
# 			"email" => "pavel.p.serikov\@gmail.com",
# 			"timezone" => "Europe/Moscow",
# 			"phone" => "9885851900"
# 	}

# };

my $api_t = '8QYOlYpxAQBqf0crsXtm45WBTfpSAVM0';

my $b64 = Mojo::Util::encode_base64($login.':'.$api_t);
warn Dumper $b64;

#warn Dumper $ua->get('https://api.timekit.io/v2/calendars' => { 'Timekit-App' => 'docs', 'Authorization' => 'Basic '.$b64 })->res->body;

# $ua->on(start => sub {
#   my ($ua, $tx) = @_;
#   $tx->req->headers->header('Timekit-App' => 'fablab61');
# });


warn Dumper $ua->get('https://api.timekit.io/v2/calendars' => { 'Timekit-App' => 'fablab61', 'Authorization' => 'Basic '.$b64 })->res->body;

##warn Dumper $ua->get('https://api.timekit.io/v2/calendars' => { 'Timekit-App' => 'docs', 'Authorization' => 'Basic '.$b64 })->res;

#warn Dumper $hash;


# problem of thow @ symbols
# warn Dumper $ua->get('https://'.$login.':'.$res->{data}{api_token}.'@api.timekit.io/v2/calendars')->res;


#warn Dumper $ua->post('api.timekit.io/v2/bookings' => { Authorization => 'Basic '.$b64 } => json => $hash)->res;