package Resource;

use strict;
use warnings;

use DateTime;
use DateTime::Duration;

use Google;

sub new {
	my ($class, $calendar) = @_;
	my $self = {calendar => $calendar};
	bless $self, $class;
}

sub schedule {
	my $self = shift;
	my $days = shift // 7;

	my $today = DateTime->today();

	my @available = ();
	my @busy = ();
	for(my $i = 0; $i < $days; ++$i) {
		my $a_start = $today->clone->add_duration(DateTime::Duration->new(days => $i, hours => 10));
		my $a_end = $a_start->clone->add_duration(DateTime::Duration->new(hours => 2));
		push @available, [$a_start, $a_end];

		my $b_start = $today->clone->add_duration(DateTime::Duration->new(days => $i, hours => 12));
		my $b_end = $b_start->clone->add_duration(DateTime::Duration->new(hours => 2));
		push @busy, [$b_start, $b_end];
	}

	{
		available => \@available,
		busy => \@busy
	};
}

sub book {
	my ($self, $user_id, $start, $end) = @_;
	Google::CalendarAPI::Events::insert($self->{calendar}, $user_id, $start, $end);
}

1;
