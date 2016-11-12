package Google;


package Google::CalendarAPI;

use strict;
use warnings;

use API::Google::GCal;

my $api;
my $user;
sub auth {
	my ($tokensfile, $user_) = @_;
	$api = API::Google::GCal->new({tokensfile => $tokensfile});
	$user = $user_;
}


package Google::CalendarAPI::Events;

use strict;
use warnings;

use DateTime;
use DateTime::Format::RFC3339;

sub insert {
	my ($calendar, $summary, $starttime, $endtime) = @_;

	my $start = DateTime->from_epoch(epoch => $starttime, time_zone => "floating");
	my $end = DateTime->from_epoch(epoch => $endtime, time_zone => "floating");

	my $time_zone = "Europe/Moscow";
	$start->set_time_zone($time_zone);
	$end->set_time_zone($time_zone);

	my $event = {};
	$event->{summary} = $summary;
	$event->{start}{dateTime} = DateTime::Format::RFC3339->format_datetime($start); 
	$event->{end}{dateTime} = DateTime::Format::RFC3339->format_datetime($end);

	$api->refresh_access_token_silent($user);
	$api->add_event($user, $calendar, $event);
}

1;
