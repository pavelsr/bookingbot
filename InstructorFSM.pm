package InstructorFSM;

use strict;
use warnings;

use FSA::Rules;

use FSMUtils;

use parent ("BaseFSM");

sub new {
	my ($class, %callbacks) = @_;

	my $self = {
		fsa => FSA::Rules->new(
			START => {
				# init machine here
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$callbacks{send_start_message}();
				},
				rules => [MENU => 1],
			},

			CANCEL => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$callbacks{send_cancel_message}();
				},
				rules => [MENU => 1],
			},

			MENU => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$callbacks{send_menu}();
				},
				rules => [SILENT_MENU => 1],
			},

			SILENT_MENU => {
				rules => [
					SCHEDULE => sub {
						my ($state, $update) = @_;
						FSMUtils::_with_text($update, sub {
							my ($text) = @_;
							$callbacks{is_schedule_selected}($text);
						});
					},

					RESOURCE => sub {
						my ($state, $update) = @_;
						FSMUtils::_with_text($update, sub {
							my ($text) = @_;
							$callbacks{is_add_record_selected}($text);
						});
					},

					MENU => \&FSMUtils::_start,

					SILENT_MENU => 1,
				],
			},

			SCHEDULE => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$callbacks{send_schedule}();
				},
				rules => [MENU => 1],
			},

			RESOURCE => {
				do => sub {
					my ($state) = @_;
					if (not defined $callbacks{send_resources}()) {
						$state->message("transition");
						$state->result(undef);
					} else {
						$state->result(1);
					}
				},
				rules => [
					RESOURCE_NOT_FOUND => sub {
						my ($state) = @_;
						not defined $state->result;
					},

					CANCEL => sub {
						my ($state, $update) = @_;
						FSMUtils::_with_text($update, sub {
							my ($text) = @_;
							$callbacks{is_cancel_operation_selected}($text);
						});
					},

					DURATION => sub {
						my ($state, $update) = @_;
						FSMUtils::_with_text($update, sub {
							my ($text) = @_;
							FSMUtils::_parse_value($state,
								$callbacks{parse_resource}, $text);
						});
					},

					RESOURCE_FAILED => 1
				],
			},

			RESOURCE_NOT_FOUND => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$callbacks{send_resource_not_found}();
				},
				rules => [MENU => 1],
			},

			RESOURCE_FAILED => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$callbacks{send_resource_failed}();
				},
				rules => [RESOURCE => 1],
			},

			DURATION => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
				},
				rules => [MENU => 1],
			},
		)
	};

	bless $self, $class;
	$self->{fsa}->start();
	$self;
}

1;
