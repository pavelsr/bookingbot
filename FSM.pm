package FSM;

use strict;
use warnings;

use FSA::Rules;

sub new {
	my ($class, %callbacks) = @_;

	my $s = {
		fsa => FSA::Rules->new(
			START => {
				# init machine here
				do => sub { shift->message('transition'); },
				rules => [BEGIN => 1],
			},

			BEGIN => {
				do => sub { shift->message('transition'); },
				rules => [RESOURCE => 1],
			},

			RESOURCE => {
				do => sub {
					$callbacks{on_resources_list}();
				},
				rules => [
					CANCEL => sub {
						my ($state, %message) = @_;
						return $message{text} eq "/cancel";
					},
					RESOURCE_INVALID => sub {
						my ($state, %message) = @_;
						return not $callbacks{is_resource_valid}($message{text});
					},
					DATETIME => sub {
						my ($state, %message) = @_;
						$state->result($message{text});
						return 1;
					},
				],
			},

			RESOURCE_INVALID => {
				do => sub {
					shift->message('transition');
					$callbacks{on_resource_invalid}();
				},
				rules => [RESOURCE => 1],
			},

			DATETIME => {
				do => sub {
					$callbacks{on_datetime_picker}();
				},
				rules => [
					CANCEL => sub {
						my ($state, %message) = @_;
						return $message{text} eq "/cancel";
					},
				],
			},

			SCHEDULE => {
				do => sub { shift->message('transition'); },
				rules => [ BEGIN => 1],
			},

			CANCEL => {
				do => sub { shift->message('transition'); },
				rules => [ BEGIN => 1],
			}
		)
	};

	bless $s, $class;

	$s->{fsa}->start();

	return $s;
}

sub next {
	my ($self, $message) = @_;
	my $last_message;
	do {
		$self->{fsa}->switch(%$message);
		$last_message = $self->{fsa}->last_message;
	} while (defined $last_message and $last_message eq 'transition')
}

1;
