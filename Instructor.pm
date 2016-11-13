package Instructor;

use strict;
use warnings;

sub new {
	my ($class, $api, $record) = @_;
	my %self = ((api => $api), %$record);
	bless \%self, $class;
}

sub name {
	my ($self) = @_;
	$self->{first_name} .
		(defined $self->{last_name} ? " " . $self->{last_name} : "");
}

sub share_contact {
	my ($self, $chat_id) = @_;
	$self->{api}->sendContact({
		chat_id => $chat_id,
		phone_number => $self->{phone_number},
		first_name => $self->{first_name},
		last_name => $self->{last_name},
	});
}

1;
