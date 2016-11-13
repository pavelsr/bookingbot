package Contacts;

use strict;
use warnings;

use Try::Tiny qw(try catch);

use Localization qw(lz);

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
		try {
			$self->{api}->sendContact({chat_id => $chat_id,
				phone_number => $contact->{phone_number},
				first_name => $contact->{first_name},
				last_name => $contact->{last_name},
			});
		} catch {
			$self->{api}->sendMessage({chat_id => $chat_id,
				text => lz("contact_format",
				$contact->{first_name}, $contact->{last_name} // "",
				$contact->{phone_number})});
		}
	}
}

1;
