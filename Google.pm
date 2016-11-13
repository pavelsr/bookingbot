package Google;


package Google::CalendarAPI;

use strict;
use warnings;

use API::Google::GCal;

use DateTimeFactory;

my $api;
my $user;
my $dtf;

sub auth {
	my ($tokensfile, $user_, $timezone) = @_;
	$api = API::Google::GCal->new({tokensfile => $tokensfile});
	$user = $user_;
	$dtf = DateTimeFactory->new($timezone);
}


package Google::CalendarAPI::Events;

use strict;
use warnings;


sub list {
	my ($calendar, $span) = @_;
	$span = $span // $dtf->span_d($dtf->tomorrow, {days => 7});

	my $start = $span->start;

	my @result = ();
	while (1) {
		my $transparentspan = $dtf->span_d($start->clone, {hours => 4});

		if (not $span->contains($transparentspan)) {
			last;
		}

		my %transparentevent = (
			summary => "251352487",
			transparent => 1,
			span => $transparentspan,
		);
		push @result, \%transparentevent;

		my $opacityspan = $dtf->span_d(
			$start->clone->add(minutes => 15), {minutes => 300});
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

	$event->{start}{dateTime} = $dtf->rfc3339($span->start);
	$event->{end}{dateTime} = $dtf->rfc3339($span->end);

	$api->refresh_access_token_silent($user);
	$api->add_event($user, $calendar, $event);
}

1;
