package FSM;

use strict;
use warnings;

use FSA::Rules;

sub new {
	my ($class, %callbacks) = @_;

	my $self = {
		fsa => FSA::Rules->new(
			START => {
				# init machine here
				do => sub {
					shift->message("transition");
					$callbacks{send_start_message}();
				},
				rules => [BEGIN => 1],
			},

			BEGIN => {
				do => sub { shift->message("transition"); },
				rules => [RESOURCE => 1],
			},

			RESOURCE => {
				do => sub {
					$callbacks{send_resources}();
				},
				rules => [
					CANCEL => \&_cancel,
					DURATION => sub {
						my ($state, %message) = @_;
						_parse_value($state,
							$callbacks{parse_resource}, $message{text});
					},
					RESOURCE_INVALID => 1
				],
			},

			RESOURCE_INVALID => {
				do => sub {
					shift->message("transition");
					$callbacks{send_resource_invalid}();
				},
				rules => [RESOURCE => 1],
			},

			DURATION => {
				do => sub {
					$callbacks{send_durations}();
				},
				rules => [
					CANCEL => \&_cancel,
					DATETIME => sub {
						my ($state, %message) = @_;
						_parse_value($state,
							$callbacks{parse_duration}, $message{text});
					},
					DURATION_INVALID => 1
				],
			},

			DURATION_INVALID => {
				do => sub {
					shift->message("transition");
					$callbacks{send_duration_invalid}();
				},
				rules => [DURATION => 1],
			},

			DATETIME => {
				do => sub {
					$callbacks{send_datetime_picker}();
				},
				rules => [
					CANCEL => \&_cancel,
					BOOK => sub {
						my ($state, %message) = @_;
						_parse_value($state,
							$callbacks{parse_datetime}, $message{text});
					},
					DATETIME_INVALID => 1
				],
			},

			DATETIME_INVALID => {
				do => sub {
					shift->message("transition");
					$callbacks{send_datetime_invalid}();
				},
				rules => [DATETIME => 1],
			},

			BOOK => {
				do => sub {
					my $state = shift;
					$state->message("transition");

					my $machine = $state->machine;
					my $resource = $machine->last_result("RESOURCE");
					my $datetime = $machine->last_result("DATETIME");
					my $duration = $machine->last_result("DURATION");

					$callbacks{book}($resource, $datetime, $duration);
				},
				rules => [BEGIN => 1],
			},

			CANCEL => {
				do => sub { shift->message("transition"); },
				rules => [BEGIN => 1],
			}
		)
	};

	bless $self, $class;
	$self->{fsa}->start();
	$self;
}

sub next {
	my ($self, $message) = @_;
	my $last_message;
	do {
		$self->{fsa}->switch(%$message);
		$last_message = $self->{fsa}->last_message;
	} while (defined $last_message and $last_message eq "transition")
}

sub _cancel {
	my ($state, %message) = @_;
	$message{text} eq "/cancel";
}

sub _parse_value {
	my ($state, $parser, $data) = @_;

	my $parsed = $parser->($data);
	if (defined $parsed) {
		$state->result($parsed);
	}

	defined $parsed;
}

1;
