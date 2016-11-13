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

use DateTime::Span;
use DateTime::Format::RFC3339;

sub list {
	my ($calendar, $span) = @_;
	$span = $span // DateTime::Span->from_datetime_and_duration(
		start => DateTime->today(time_zone => $timezone)->add(days => 1),
		days => 7);

	my $start = $span->start;

	my @result = ();
	while (1) {
		my $transparentspan = DateTime::Span->from_datetime_and_duration(
			start => $start->clone, hours => 4);

		if (not $span->contains($transparentspan)) {
			last;
		}

		my %event = (
			summary => "251352487",
			transparent => 1,
			span => $transparentspan,
		);
		push @result, \%event;

		my $opacityspan = DateTime::Span->from_datetime_and_duration(
			start => $start->clone->add(hours => 1), minutes => 90);
		my %opacityevent = (
			summary => "251352487",
			span => $opacityspan,
		);
		push @result, \%opacityevent;

		$start->add(hours => 6);
	}

	\@result;
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
