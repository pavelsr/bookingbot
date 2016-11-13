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
	my @result = sort { $a cmp $b } keys %$resources;
	\@result;
}

sub exists {
	my ($self, $name) = @_;
	my $resources = $self->{resources};
	grep { $_ eq $name } keys %$resources;
}

sub vacancies {
	my ($self, $name, $duration, $span) = @_;
	$self->{resources}->{$name}->vacancies($duration, $span);
}

sub book {
	my ($self, $user_id, $name, $span) = @_;
	$self->{resources}->{$name}->book($user_id, $span);
}

1;
