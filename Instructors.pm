package Instructors;

use strict;
use warnings;

use Instructor;
use Localization qw(lz dt);

sub new {
	my ($class, $api, $config) = @_;

	my %instructors = ();
	foreach my $id (keys %$config) {
		my $record = $config->{$id};
		$instructors{$id} = Instructor->new($api, $record);
	}

	my $self = {api => $api, instructors => \%instructors};
	bless $self, $class;
}

sub share_contact {
	my ($self, $id, $chat_id) = @_;
	$self->{instructors}->{$id}->share_contact($chat_id);
}

sub notify_new_book {
	my ($self, $id, $user, $resource, $span) = @_;

	$self->{api}->sendMessage({
		chat_id => $id,
		text => lz("instructor_new_book",
			$resource, dt($span->start), dt($span->end),
			$user->{id}, $user->{first_name}, $user->{last_name} // lz("na"),
			$user->{username} // lz("na"))
	});
}

1;
