package Instructors;

use strict;
use warnings;

use Instructor;

sub new {
	my ($class, $api, $config) = @_;

	my %instructors = ();
	foreach my $id (keys %$config) {
		my $record = $config->{$id};
		$instructors{$id} = Instructor->new($api, $record);
	}

	my $self = {instructors => \%instructors};
	bless $self, $class;
}

sub share_contact {
	my ($self, $id, $chat_id) = @_;
	$self->{instructors}->{$id}->share_contact($chat_id);
}

1;
