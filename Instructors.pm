package Instructors;

use strict;
use warnings;

use Instructor;
use Localization qw(lz dt);

sub new {
	my ($class, $api, $contacts, $groups, $config) = @_;

	my %instructors = ();
	foreach my $id (keys %$config) {
		my $record = $config->{$id};
		$instructors{$id} = Instructor->new($api, $record);
	}

	my $self = {api => $api, contacts => $contacts, groups => $groups, instructors => \%instructors};
	bless $self, $class;
}

sub exists {
	my ($self, $id) = @_;
	defined $self->{instructors}->{$id};
}

sub share_contact {
	my ($self, $id, $chat_id) = @_;
	$self->{instructors}->{$id}->share_contact($chat_id);
}

sub notify_instructor {
	my ($self, $id, $user, $resource, $span) = @_;

	$self->{api}->sendMessage({chat_id => $id,
		text => lz("instructor_new_book", $resource,
			dt($span->start), dt($span->end))
	});
	$self->{contacts}->send($id, $user->{id});
}

sub notify_groups {
	my ($self, $id, $user, $resource, $span) = @_;

	my $text = $self->exists($id)
		? lz("group_new_book",
				$self->{instructors}->{$id}->name . " ($id)",
				$resource, dt($span->start), dt($span->end)) 
		: lz("group_new_book_fallback",
				$resource, dt($span->start), dt($span->end));

	foreach my $group (@{$self->{groups}->{groups}}) {
		$self->{api}->sendMessage({chat_id => $group, text => $text});
		$self->{contacts}->send($group, $user->{id});
	}
}

1;
