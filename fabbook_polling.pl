#!/usr/bin/env perl
# Demonstte getUpdates + offset usage

package BroneBot;
use Mojolicious::Lite;
use Data::Dumper;
use WWW::Telegram::BotAPI;
use common::sense;

#use lib $ENV {SLIBLOCATION} || "$FindBin::Bin/serikoff.lib" || '/home/pavel/projects/serikoff.lib';
use lib '/home/pavel/projects/serikoff.lib';
use Serikoff::Telegram::Polling qw(get_last_messages);
use Serikoff::Telegram::Sessions;
use Serikoff::Telegram::Screens;
use Serikoff::Telegram::Keyboards qw(create_one_time_keyboard);
use Serikoff::Telegram::Restgram;
use JSON qw(encode_json);

use FSM;

my $jsonconfig = plugin 'JSONConfig';

BEGIN { $ENV{TELEGRAM_BOTAPI_DEBUG} = 1 };

my $api = WWW::Telegram::BotAPI->new(
    token => '280790722:AAHwv_-7KiBrTIlgwPJqSyV2rXd_ISIFkO0'
);

# Create a new session with defined start and stop commands
my $sessions = Serikoff::Telegram::Sessions->new(
	$jsonconfig->{session}{start}, 
	$jsonconfig->{session}{stop}
);

my $screens = Serikoff::Telegram::Screens->new(
	$jsonconfig->{screens}
);

my $restgram = Serikoff::Telegram::Restgram->new();

my $polling_interval = 1;

# Extract keys by screen hash
sub extract_keys {
	my $screen_hash = shift;
	#warn "extract_keys() : ".Dumper $screen_hash;
	my @keys;
	my @keyboard = @{$screen_hash->{$jsonconfig->{keyboard_key_at_screen}}};
	for (@keyboard) {
		push @keys, $_->{key};
	}
	return \@keys;
}

sub _log_info {
	my ($session_id, $message) = @_;
	app->log->info("[$session_id] " . $message);
}

# sid - session id, used in logs to distinguish one session from another
my $sid = 0;

# chat to state machine hash
my %machines = ();

Mojo::IOLoop->recurring($polling_interval => sub {
	my $hash = get_last_messages($api);
	while (my ($chat_id, $update) = each(%$hash)) {
		$sid++;

		_log_info($sid, "new message: " . encode_json($update->{message}));

		if (substr($update->{message}{text}, 0, 1) eq '%') {
			# temporary mode for restgram testing
			_log_info($sid, "restgram testing");

			my $phone = substr($update->{message}{text}, 1);
			my $answer = encode_json($restgram->get_full_user_by_phone($phone));
			_log_info($sid, "answer: $answer");

			$api->sendMessage({chat_id => $chat_id, text => $answer});
		} else {
			if (not exists $machines{$chat_id}) {
				$machines{$chat_id} = FSM->new(
					on_resources_list => sub {
						$api->sendMessage({chat_id => $chat_id, text => "Select Resource", reply_markup => create_one_time_keyboard(['Machine 1', 'Machine 2'])});
					},

					is_resource_valid => sub { shift eq 'Machine 1'; },

					on_resource_invalid => sub {
						$api->sendMessage({chat_id => $chat_id, text => "Selected resource is invalid"});
					},

					on_datetime_picker => sub {
						$api->sendMessage({chat_id => $chat_id, text => "Select Date"});
					}
				);
				_log_info($sid, "finite state machine created");
			}
			$machines{$chat_id}->next($update->{message});
			_log_info($sid, "moved to next state");
		}

		_log_info($sid, "message processing finished");
	}
});

app->start;

#$api->sendMessage({ chat_id => $chat_id, text => "Next screen...", reply_markup => create_one_time_keyboard($btns) });
