package Google;


package Google::CalendarAPI;

use strict;
use warnings;

use API::Google::GCal;

my $api;
my $user;
my $timezone;

sub auth {
	my ($tokensfile, $user_, $timezone_) = @_;
	$api = API::Google::GCal->new({tokensfile => $tokensfile});
	$user = $user_;
	$timezone = $timezone_;
}


package Google::CalendarAPI::Events;

use strict;
use warnings;

use DateTime::Format::RFC3339;

sub list {
}

sub insert {
	my ($calendar, $summary, $span) = @_;

	my $event = {};
	$event->{summary} = $summary;

	$event->{start}{dateTime} =
		DateTime::Format::RFC3339->format_datetime($span->start);

	$event->{end}{dateTime} =
		DateTime::Format::RFC3339->format_datetime($span->end);

	$api->refresh_access_token_silent($user);
	$api->add_event($user, $calendar, $event);
}

1;
