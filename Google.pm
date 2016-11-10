package Google;


package Google::CalendarAPI;

use strict;
use warnings;

use API::Google::GCal;

my $api;
sub auth {
	$api = API::Google::GCal->new({ tokensfile => shift });
}


package Google::CalendarAPI::Events;

use strict;
use warnings;

use DateTime;
use DateTime::Duration;
use DateTime::Format::RFC3339;

sub insert {
	my ($summary, $start) = @_;

	my $user = 'fablab61ru@gmail.com';
	my $calendar = 'primary';

	my $end = $start->clone->add_duration(DateTime::Duration->new(hours => 1));

	my $event = {};
	$event->{summary} = $summary;
	$event->{start}{dateTime} = DateTime::Format::RFC3339->format_datetime($start); 
	$event->{end}{dateTime} = DateTime::Format::RFC3339->format_datetime($end);

	$api->refresh_access_token_silent($user);
	$api->add_event($user, $calendar, $event);
}


1;
