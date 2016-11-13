package Resource;

use strict;
use warnings;

use DateTime::SpanSet;

use Google;

sub new {
	my ($class, $calendar) = @_;
	my $self = {calendar => $calendar};
	bless $self, $class;
}

sub vacancies {
	my ($self, $duration, $span) = @_;

	my $events = Google::CalendarAPI::Events::list($self->{calendar}, $span);

	my @free = map { $_->{span} } grep { $_->{transparent} } @$events;
	my @busy = map { $_->{span} } grep { not $_->{transparent} } @$events;

	my $freeset = DateTime::SpanSet->from_spans(spans => \@free);
	my $busyset = DateTime::SpanSet->from_spans(spans => \@busy);

	my @result = $freeset->complement($busyset)->grep(sub {
		DateTime::Duration->compare($duration, $_->duration, $_->start) <= 0;
	})->as_list;

	\@result;
}

sub book {
	my ($self, $user_id, $span) = @_;
	Google::CalendarAPI::Events::insert($self->{calendar}, $user_id, $span);
}

1;
