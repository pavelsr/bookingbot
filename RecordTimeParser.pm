package RecordTimeParser;

use strict;
use warnings;

use Localization qw(lz);

sub _tokenize {
	my ($text) = @_;
	my %result = ();

	my $regexp = lz("span_regexp");
	if($text =~ m/${regexp}/g) {
		$result{day} = $1 // lz("today");
		$result{preposition} = $2 // "";
		$result{hour1} = $3 // 0;
		$result{minute1} = $4 // 0;
		$result{hour2} = $5 // 0;
		$result{minute2} = $6 // 0;
	}

	\%result;
}

sub parse_span {
	my ($text) = @_;

	my $regexp = lz("span_regexp");
	if($text =~ m/${regexp}/g) {
		my $day = $1 // lz("today");
		my $from_hour = $2 // 0;
		my $from_minute = $3 // 0;
		my $to_hour = $4 // ($from_hour + 1);
		my $to_minute = $5 // 0;
		print "success/$day/$from_hour/$from_minute/$to_hour/$to_minute";
	}

#	my $date = new Date::Manip::Date [
#		"Language", lz("date_manip_language"),
#		"DateFormat", lz("date_manip_format"),
#		"YYtoYYYY", 0,
#		"Format_MMMYYYY", "first",
#	];
#	$date->parse($text) ? undef : $self->epoch($date->printf("%s"));

#	$self->span_se(
#		$self->tomorrow->add(hours => 10),
#		$self->tomorrow->add(hours => 12));
}

1;
