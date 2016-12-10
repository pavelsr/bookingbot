package DateTimeFactory;

# ABSTRACT: Hepler methods for DateTime "get" methods (https://metacpan.org/pod/DateTime#Get-Methods)

=head1 SYNOPSIS

    use DateTimeFactory;
    my $dtf = DateTimeFactory->new;
	my $dtf = DateTimeFactory->new($default_timezone);
	$dtf->set_default_timezone($timezone);
	$dtf->now;

 
=cut

=head1 ARCHITECTURE

This module builds all needed operations with DateTime and DateTime::* objects into a single module

=cut

use strict;
use warnings;

use Date::Parse qw(str2time);
use DateTime;
use DateTime::Duration;
use DateTime::Format::RFC3339;
use DateTime::Span;
use DateTime::SpanSet;

use Scalar::Util qw(blessed);

my $default_timezone;

sub set_default_timezone {
	$default_timezone = shift;
}

sub new {
	my ($class, $timezone) = @_;
	my $self = {timezone => $timezone // $default_timezone};
	bless $self, $class;
}

=method now

Returns current datetime as DateTime object. Take timezone into account

=cut

sub now {
	my ($self) = @_;
	die unless defined $self->{timezone};

	DateTime->now(time_zone => $self->{timezone});
}


=method now

Returns 00:00 of tomorrow as DateTime object. Take timezone into account

=cut


sub tomorrow {
	my ($self) = @_;
	die unless defined $self->{timezone};

	DateTime->today(time_zone => $self->{timezone})->add(days => 1);
}


=method now

Return DateTime object created from specified unix time (seconds since Jan 01 1970 UTC)

$dtf->epoch(148137608)

=cut


sub epoch {
	my ($self, $unixtime) = @_;
	die unless defined $self->{timezone};

	my $result = DateTime->from_epoch(
		epoch => $unixtime, time_zone => "floating");
	$result->set_time_zone($self->{timezone});

	$result;
}

=method cmp

Implements DateTime->compare

https://metacpan.org/pod/DateTime#DateTime-compare-dt1-dt2-DateTime-compare_ignore_floating-dt1-dt2

=cut

sub cmp {
	my ($self, $left, $right) = @_;
	DateTime->compare($left, $right);
}

=method parse

=cut

sub parse {
	my ($self, $inputstr) = @_;
	my $unixtime = str2time($inputstr);
	defined $unixtime ? $self->epoch($unixtime) : undef;
}

=method parse_rfc3339

=cut

sub parse_rfc3339 {
	my ($self, $inputstr) = @_;
	die unless defined $self->{timezone};

	my $result = DateTime::Format::RFC3339->parse_datetime($inputstr);
	$result->set_time_zone($self->{timezone});
}

=method dur

=cut

sub dur {
	my ($self, %params) = @_;
	DateTime::Duration->new(%params);
}

=method durcmp

=cut

sub durcmp {
	my ($self, $left, $right, $start) = @_;
	DateTime::Duration->compare($left, $right, $start);
}

=method rfc3339

=cut

sub rfc3339 {
	my ($self, $datetime) = @_;
	DateTime::Format::RFC3339->format_datetime($datetime);
}

=method span_d

=cut

sub span_d {
	my ($self, $datetime, $data) = @_;
	my $duration = blessed($data) ? $data : $self->dur(%$data);
	DateTime::Span->from_datetime_and_duration(
		start => $datetime, duration => $duration);
}

=method span_se

=cut

sub span_se {
	my ($self, $start, $end) = @_;
	DateTime::Span->from_datetimes(start => $start, before => $end);
}

=method spanset

=cut

sub spanset {
	my ($self, $spans) = @_;
	DateTime::SpanSet->from_spans(spans => $spans);
}

1;
