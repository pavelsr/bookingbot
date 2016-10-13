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
				do => sub {
					shift->message('transition');
					$callbacks{send_start_message}();
				},
				rules => [BEGIN => 1],
			},

			BEGIN => {
				do => sub { shift->message('transition'); },
				rules => [RESOURCE => 1],
			},

			RESOURCE => {
				do => sub {
					$callbacks{send_resources_list}();
				},
				rules => [
					CANCEL => sub {
						my ($state, %message) = @_;
						return $message{text} eq "/cancel";
					},
					DATETIME => sub {
						my ($state, %message) = @_;
						my $resource = $message{text};
						my $is_valid = $callbacks{parse_resource}($resource);
						if ($is_valid) {
							$state->result($resource);
						}
						return $is_valid;
					},
					RESOURCE_INVALID => 1
				],
			},

			RESOURCE_INVALID => {
				do => sub {
					shift->message('transition');
					$callbacks{send_resource_invalid}();
				},
				rules => [RESOURCE => 1],
			},

			DATETIME => {
				do => sub {
					$callbacks{send_datetime_picker}();
				},
				rules => [
					CANCEL => sub {
						my ($state, %message) = @_;
						return $message{text} eq "/cancel";
					},
					BOOK => sub {
						my ($state, %message) = @_;
						my $result = $callbacks{parse_datetime}($message{text});
						if (defined $result) {
							$state->result($result);
						}
						return defined $result;
					},
					DATETIME_INVALID => 1
				],
			},

			DATETIME_INVALID => {
				do => sub {
					shift->message('transition');
					$callbacks{send_datetime_invalid}();
				},
				rules => [DATETIME => 1],
			},

			BOOK => {
				do => sub {
					my $state = shift;
					$state->message('transition');

					my $machine = $state->machine;
					my $resource = $machine->last_result('RESOURCE');
					my $datetime = $machine->last_result('DATETIME');

					$callbacks{book}($resource, $datetime);
				},
				rules => [BEGIN => 1],
			},

			CANCEL => {
				do => sub { shift->message('transition'); },
				rules => [BEGIN => 1],
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
