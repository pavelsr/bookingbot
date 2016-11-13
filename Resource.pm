package Resource;

use strict;
use warnings;

use DateTimeFactory;
use Google;

sub new {
	my ($class, $record) = @_;
	my %self = ((dtf => DateTimeFactory->new()), %$record);
	bless \%self, $class;
}

sub vacancies {
	my ($self, $duration, $span) = @_;

	my $dtf = $self->{dtf};

	my $events = Google::CalendarAPI::Events::list($self->{calendar}, $span);

	my @free = map { $_->{span} } grep { $_->{transparent} } @$events;
	my @busy = map { $_->{span} } grep { not $_->{transparent} } @$events;

	my $freeset = $dtf->spanset(\@free);
	my $busyset = $dtf->spanset(\@busy);

	my @result = $freeset->complement($busyset)->grep(sub {
		$dtf->durcmp($duration, $_->duration, $_->start) <= 0;
	})->as_list;

	\@result;
}

sub book {
	my ($self, $user_id, $span) = @_;
	Google::CalendarAPI::Events::insert($self->{calendar}, $user_id, $span);
}

1;
