#!/usr/bin/env perl

package BookingBot;

use common::sense;
use Date::Parse qw(str2time);
use JSON qw(encode_json);
use Mojolicious::Lite;
use WWW::Telegram::BotAPI;

use lib "serikoff.lib";
use Serikoff::Telegram::Keyboards qw(create_one_time_keyboard);
use Serikoff::Telegram::Polling qw(get_last_messages);
use Serikoff::Telegram::Restgram;

use FSM;
use Google;
use Localization qw(lz);
use Resources;

BEGIN { $ENV{TELEGRAM_BOTAPI_DEBUG} = 1 };

my $api = WWW::Telegram::BotAPI->new(
	token => "222684756:AAHSkWGC101ooGT3UYSYxofC8x3BD1PT5po"
);

my $jsonconfig = plugin "JSONConfig";

my $restgram = Serikoff::Telegram::Restgram->new();
my $resources = Resources->new($jsonconfig->{resources});

my $polling_interval = 1;

# sid - session id, used in logs to distinguish one session from another
my $sid = 0;

# chat to state machine hash
my %machines = ();


sub _log_info {
	my ($session_id, $message) = @_;
	app->log->info("[$session_id] " . $message);
}

# extract keys by screen hash
sub extract_keys {
	my $screen_hash = shift;
	my @keys;
	my @keyboard = @{$screen_hash->{$jsonconfig->{keyboard_key_at_screen}}};
	for (@keyboard) {
		push @keys, $_->{key};
	}
	\@keys;
}

sub new_fsm {
	my ($user_id, $chat_id) = @_;

	FSM->new(
		send_start_message => sub {
			$api->sendMessage({chat_id => $chat_id, text => lz("welcome")});
		},

		send_resources => sub {
			$api->sendMessage({
				chat_id => $chat_id,
				text => lz("select_resource"),
				reply_markup => create_one_time_keyboard($resources->names, 1)
			});
		},

		parse_resource => sub {
			my ($name) = @_;
			$resources->exists($name) ? $name : undef;
		},

		send_resource_invalid => sub {
			$api->sendMessage({chat_id => $chat_id, text => lz("invalid_resource")});
		},

		send_durations => sub {
			my $durations = $jsonconfig->{durations};

			my @durations_menu =
				map { lz($_->[1]) }
				sort { $a->[0] <=> $b->[0] }
				map { [$durations->{$_}, $_] } keys %$durations;

			$api->sendMessage({
				chat_id => $chat_id,
				text => lz("select_duration"),
				reply_markup => create_one_time_keyboard(\@durations_menu, 1)
			});
		},

		parse_duration => sub {
			my ($input) = @_;
			my $durations = $jsonconfig->{durations};
			my @result = grep { lz($_) eq $input } keys %$durations;
			$durations->{$result[0]};
		},

		send_duration_invalid => sub {
			$api->sendMessage({chat_id => $chat_id, text => lz("invalid_duration")});
		},

		send_datetime_picker => sub {
			my $resource = shift;
			$api->sendMessage({chat_id => $chat_id, text => lz("enter_date")});

			#$api->sendMessage({
			#chat_id => $chat_id,
			#text => "Select day.",
			#reply_markup => create_one_time_keyboard(
			#map { $_->strftime("%a, %d %b %Y") } Resources::available_dates($resource), 1)
			#});
		},

		parse_datetime => sub {
			str2time(shift);
		},

		send_datetime_invalid => sub {
			$api->sendMessage({chat_id => $chat_id, text => lz("invalid_date_format")});
		},

		book => sub {
			my ($name, $datetime, $duration) = @_;
			$resources->book($user_id, $name, $datetime, $duration);
			$api->sendMessage({chat_id => $chat_id, text => lz("booked", $name, scalar localtime $datetime)});
		},
	);
}


Google::CalendarAPI::auth("gapi.conf", "fablab61ru\@gmail.com", $jsonconfig->{timezone});

_log_info($sid, "ready to process incoming messages");

Mojo::IOLoop->recurring($polling_interval => sub {
	my $hash = get_last_messages($api);
	while (my ($chat_id, $update) = each(%$hash)) {
		$sid++;

		_log_info($sid, "new message: " . encode_json($update->{message}));

		if (substr($update->{message}{text}, 0, 1) eq "%") {
			# temporary mode for restgram testing
			_log_info($sid, "restgram testing");

			my $phone = substr($update->{message}{text}, 1);
			my $answer = encode_json($restgram->get_full_user_by_phone($phone));
			_log_info($sid, "answer: $answer");

			$api->sendMessage({chat_id => $chat_id, text => $answer});
		} else {
			if (not exists $machines{$chat_id}) {
				$machines{$chat_id} = new_fsm($update->{message}->{from}->{id}, $chat_id);
				_log_info($sid, "finite state machine created");
			}
			$machines{$chat_id}->next($update->{message});
			_log_info($sid, "moved to next state");
		}

		_log_info($sid, "message processing finished");
	}
});

app->start;
