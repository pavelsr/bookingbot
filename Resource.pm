package Resource;

use strict;
use warnings;

use Google;

sub new {
	my ($class, $calendar) = @_;
	my $self = {calendar => $calendar};
	bless $self, $class;
}

sub schedule {
}

sub book {
	my ($self, $user_id, $span) = @_;
	Google::CalendarAPI::Events::insert($self->{calendar}, $user_id, $span);
}

1;
