package Instructors;

# ABSTRACT: 

=head1 SYNOPSIS

    use Instructors;
    my $instructors = Instructors->new($api, $contacts, $groups, $config->{instructors});
    # $contacts = Contacts->new
	

=head1 ARCHITECTURE


=cut


use strict;
use warnings;

use Instructor;
use Localization qw(lz dt);


=method new

Create new Instructor objects from config $hash.
Each object has unique reference, by default it's key config of $hash

This object is also containing references to Contacts and Groups objects

=cut


sub new {
	my ($class, $api, $contacts, $groups, $config) = @_;   # bad design! need to rewrite to hash

	my %instructors = ();  # better to use hashref
	foreach my $name (keys %$config) {
		my $record = $config->{$name};
		$instructors{$name} = Instructor->new($api, $record);
	}

	my $self = {api => $api, contacts => $contacts, groups => $groups,
		instructors => \%instructors};
	bless $self, $class;
}


=method exists

$instructors->exists('pavel.p.serikov@gmail.com');

Return true if instructor exists at $self->{instructors} (initialized by default from config)

=cut

sub exists {
	my ($self, $name) = @_;
	defined $self->{instructors}->{$name};
}

=method is_instructor

Return true if given telegram user_id is an instructor

=cut


sub is_instructor {
	my ($self, $id) = @_;
	my @result = grep { $_->id eq $id } values %{$self->{instructors}};
	scalar @result > 0;
}


=method share_contact

Share instructor contact with given id ($name, by default it's email) with telegram $chat_id

=cut

sub share_contact {
	my ($self, $name, $chat_id) = @_;
	die unless $self->exists($name);

	$self->{instructors}->{$name}->share_contact($chat_id);
}

=method notify_instructor

$instructors->notify_instructor($instructor_id_who_must_be_notified, $user_which_booked, $resource, $span);
# $resource and $span are values which must be inserted into instructor_new_book template of Localization.pm

Send info about booking to instructor and share with instructor a contact of user which made booking

=cut

sub notify_instructor {
	my ($self, $name, $user, $resource, $span) = @_;   # bad
	die unless $self->exists($name);

	my $instructor = $self->{instructors}->{$name};
	$self->{api}->send_message({chat_id => $instructor->{id},
		text => lz("instructor_new_book", $resource,
			dt($span->start), dt($span->end))
	});
	$self->{contacts}->send($instructor->{id}, $user->{id});
}


=method

Make notification of list of groups defined at $self->{instructors}.

There is information in notification text: who booked, when and which instructor was assigned

=cut


sub notify_groups {
	my ($self, $name, $user, $resource, $span) = @_;

	my $text = $self->exists($name)
		? lz("group_new_book",
				$self->{instructors}->{$name}->fullname, $name,
				$resource, dt($span->start), dt($span->end)) 
		: lz("group_new_book_fallback",
				$resource, dt($span->start), dt($span->end));

	foreach my $group (@{$self->{groups}->{groups}}) {
		$self->{api}->send_message({chat_id => $group, text => $text});
		$self->{contacts}->send($group, $user->{id});
	}
}

1;
