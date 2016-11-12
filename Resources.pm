package Resources;

use strict;
use warnings;

use Resource;

sub new {
	my ($class, $config) = @_;

	my %resources = ();
	foreach my $record (@$config) {
		my $resource = Resource->new($record->{calendar});
		$resources{$record->{name}} = $resource;
	}

	my $self = {resources => \%resources};
	bless $self, $class;
}

sub names {
	my ($self) = @_;
	my $resources = $self->{resources};
	my @result = keys %$resources;
	\@result;
}

sub exists {
	my ($self, $name) = @_;
	my $resources = $self->{resources};
	grep { $_ eq $name } keys %$resources;
}

sub schedule {
	my ($self, $name) = @_;
	$self->{resources}->{$name}->schedule;
}

sub book {
	my ($self, $user_id, $name, $start, $end) = @_;
	$self->{resources}->{$name}->book($user_id, $start, $end);
}

1;
