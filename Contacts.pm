package Contacts;

use strict;
use warnings;

sub new {
	my ($class, $api) = @_;
	my $self = {api => $api, contacts => {}};
	bless $self, $class;
}

sub add {
	my ($self, $user_id, $contact) = @_;
	$self->{contacts}->{$user_id} = $contact;
}

sub send {
	my ($self, $chat_id, $user_id) = @_;

	my $contact = $self->{contacts}->{$user_id};
	if (defined $contact) {
		$self->{api}->sendContact({
			chat_id => $chat_id,
			phone_number => $contact->{phone_number},
			first_name => $contact->{first_name},
			last_name => $contact->{last_name},
		});
		1;
	}
}

1;
