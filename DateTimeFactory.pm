package DateTimeFactory;

use strict;
use warnings;

use DateTime;
use DateTime::Duration;
use DateTime::Format::RFC3339;
use DateTime::Span;
use DateTime::SpanSet;

use Scalar::Util qw(blessed);

sub new {
	my ($class, $timezone) = @_;
	my $self = {timezone => $timezone};
	bless $self, $class;
}

sub tomorrow {
	my ($self) = @_;
	die unless defined $self->{timezone};

	DateTime->today(time_zone => $self->{timezone})->add(days => 1);
}

sub epoch {
	my ($self, $unixtime) = @_;
	die unless defined $self->{timezone};

	my $result = DateTime->from_epoch(
		epoch => $unixtime, time_zone => "floating");
	$result->set_time_zone($self->{timezone});

	$result;
}

sub dur {
	my ($self, %params) = @_;
	DateTime::Duration->new(%params);
}

sub durcmp {
	my ($self, $left, $right, $start) = @_;
	DateTime::Duration->compare($left, $right, $start);
}

sub rfc3339 {
	my ($self, $datetime) = @_;
	DateTime::Format::RFC3339->format_datetime($datetime);
}

sub span_d {
	my ($self, $datetime, $data) = @_;
	my $duration = blessed($data) ? $data : $self->dur(%$data);
	DateTime::Span->from_datetime_and_duration(
		start => $datetime, duration => $duration);
}

sub spanset {
	my ($self, $spans) = @_;
	DateTime::SpanSet->from_spans(spans => $spans);
}

1;
