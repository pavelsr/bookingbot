package Instructor;

use strict;
use warnings;

use Try::Tiny qw(try catch);

use Localization qw(lz);

sub new {
	my ($class, $api, $record) = @_;
	my %self = ((api => $api), %$record);
	bless \%self, $class;
}

sub fullname {
	my ($self) = @_;
	my $first_name = $self->{first_name};
	my $last_name = $self->{last_name} // "";
	my $result = "$first_name $last_name";
	$result =~ s/^\s+|\s+$//g; # trim
	$result;
}

sub share_contact {
	my ($self, $chat_id) = @_;

	$self->{api}->sendMessage({chat_id => $chat_id,
		text => lz("instructor_contact")});

	try {
		$self->{api}->sendContact({chat_id => $chat_id,
			phone_number => $self->{phone_number},
			first_name => $self->{first_name},
			last_name => $self->{last_name},
		});
	} catch {
		$self->{api}->sendMessage({chat_id => $chat_id, text =>
			lz("contact_format", $self->{first_name}, $self->{last_name} // "",
			$self->{phone_number})});
	}
}

1;
