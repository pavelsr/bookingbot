package Contacts;

# ABSTRACT: Module for exchanging contacts via Telegram Bot API

=head1 SYNOPSIS

    use Contacts;
    my $contacts = Contacts->new($telegram_api);
    # $telegram_api - object which provide methods of Telegram API (at least send_contact and send_message methods)
    $contacts->add($user_id, $contact); # it makes sense to have $contact->{phone_number}
    $contact->fullname($user_id);
    $contact->send($chat_id, $user_id); # $user_id = id of contact to send
    
=cut

=head1 ARCHITECTURE

In fact, this module is helping to implement https://core.telegram.org/bots/api#sendcontact

Stores all added contacts is $self->{contacts} (like a cache)

By default $contact includes first_name, last_name, phone_number

Can't work without Telegram API

=cut

use strict;
use warnings;
use Try::Tiny qw(try catch);
use Localization qw(lz);

sub new {
	my ($class, $api) = @_;
	my $self = {api => $api, contacts => {}};
	bless $self, $class;
}

=method add

Add contact into in-memory storage (known contacts)

=cut

sub add {
	my ($self, $user_id, $contact) = @_;
	$self->{contacts}->{$user_id} = $contact;
}

=method fullname

Getting full name (first_name + last_name ) by Telegram user_id.

Working only if contact was added into known contacts (in-memory data storage)

return string

=cut

sub fullname {
	my ($self, $user_id) = @_;

	my $contact = $self->{contacts}->{$user_id};
	my $first_name = $contact->{first_name};
	my $last_name = $contact->{last_name} // "";

	my $result = "$first_name $last_name";
	$result =~ s/^\s+|\s+$//g; # trim
	$result;
}


=method send

$contact->send($chat_id, $user_id);

Share a contact of $user_id with specified $chat_id

WARNING! Before sending a contact you need to add it

=cut

sub send {
	my ($self, $chat_id, $user_id) = @_;

	my $contact = $self->{contacts}->{$user_id};
	if (defined $contact) {
		try {
			$self->{api}->send_contact({chat_id => $chat_id,
					contact => $contact});
		} catch {
			$self->{api}->send_message({chat_id => $chat_id,
				text => lz("contact_format",
				$contact->{first_name}, $contact->{last_name} // "",
				$contact->{phone_number})});
		}
	}
}

1;
