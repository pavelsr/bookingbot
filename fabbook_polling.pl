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

use DateTimeFactory;
use Contacts;
use FSM;
use Google;
use Groups;
use Instructors;
use Localization qw(lz dt);
use Resources;

my $jsonconfig = plugin "JSONConfig";

BEGIN { $ENV{TELEGRAM_BOTAPI_DEBUG} = 1 };
my $api = WWW::Telegram::BotAPI->new(
	token => "222684756:AAHSkWGC101ooGT3UYSYxofC8x3BD1PT5po"
);

my $contacts = Contacts->new($api);
my $dtf = DateTimeFactory->new($jsonconfig->{timezone});
my $groups = Groups->new($api->getMe->{result}->{id});
my $instructors = Instructors->new($api, $contacts, $groups, $jsonconfig->{instructors});
my $resources = Resources->new($jsonconfig->{resources});
my $restgram = Serikoff::Telegram::Restgram->new();
my %machines = ();

# sid - session id, used in logs to distinguish one session from another
my $sid = 0;
sub _log_info {
	my ($session_id, $message) = @_;
	app->log->info("[$session_id] " . $message);
}

sub new_fsm {
	my ($user, $chat_id) = @_;

	FSM->new(
		send_start_message => sub {
			$api->sendMessage({chat_id => $chat_id, text => lz("start")});
		},

		send_contact_message => sub {
			$api->sendMessage({chat_id => $chat_id, text => lz("contact")});
		},

		save_contact => sub {
			my ($contact) = @_;
			if (defined $contact) {
				$contacts->add($user->{id}, $contact);
				1;
			}
		},

		send_contact_failed => sub {
			$api->sendMessage({
					chat_id => $chat_id, text => lz("invalid_contact")});
		},

		send_begin_message => sub {
			$api->sendMessage({chat_id => $chat_id, text => lz("begin")});
		},

		send_resources => sub {
			my @durations = sort { $a <=> $b }
				values %{$jsonconfig->{durations}};
			my $min = $dtf->dur(minutes => shift @durations);

			my @keyboard = grep {
				scalar @{$resources->vacancies($_, $min)} > 0;
			} @{$resources->names};

			if (scalar @keyboard > 0) {
				$api->sendMessage({
					chat_id => $chat_id,
					text => lz("select_resource"),
					reply_markup => create_one_time_keyboard(\@keyboard, 1)
				});
			} else {
				undef;
			}
		},

		parse_resource => sub {
			my ($name) = @_;
			$resources->exists($name) ? $name : undef;
		},

		send_resource_not_found => sub {
			$api->sendMessage({
				chat_id => $chat_id, text => lz("resource_not_found")});
		},

		send_resource_failed => sub {
			$api->sendMessage({
				chat_id => $chat_id, text => lz("invalid_resource")});
		},

		send_durations => sub {
			my ($resource) = @_;

			my $durations = $jsonconfig->{durations};

			my @keyboard =
				map { lz($_->[1]) }
				sort { $a->[0] <=> $b->[0] }
				map { [$durations->{$_}, $_] }
				grep {
					my $duration = $dtf->dur(minutes => $durations->{$_});
					my $vacancies = $resources->vacancies($resource, $duration);
					scalar @$vacancies > 0;
				} keys %$durations;

			if (scalar @keyboard > 0) {
				$api->sendMessage({
					chat_id => $chat_id,
					text => lz("select_duration"),
					REPLY_MARKUP => create_one_time_keyboard(\@keyboard, 1)
				});
			} else {
				undef;
			}
		},

		parse_duration => sub {
			my ($arg) = @_;
			my $durations = $jsonconfig->{durations};
			my @result = grep { lz($_) eq $arg } keys %$durations;
			scalar @result > 0
				? $dtf->dur(minutes => $durations->{$result[0]})
				: undef;
		},

		send_duration_not_found => sub {
			$api->sendMessage({
				chat_id => $chat_id, text => lz("duration_not_found")});
		},

		send_duration_failed => sub {
			$api->sendMessage({
				chat_id => $chat_id, text => lz("invalid_duration")});
		},

		send_datetime_selector => sub {
			my ($resource, $duration) = @_;

			my $vacancies = $resources->vacancies($resource, $duration);
			my @keyboard = map { dt($_->{span}->start) } @$vacancies;

			$api->sendMessage({
				chat_id => $chat_id,
				text => lz("select_datetime"),
				reply_markup => create_one_time_keyboard(\@keyboard, 1)
			});
		},

		parse_datetime => sub {
			my ($inputstr) = @_;
			my $unixtime = str2time($inputstr);
			defined $unixtime ? $dtf->epoch($unixtime) : undef;
		},

		send_datetime_failed => sub {
			$api->sendMessage({
				chat_id => $chat_id, text => lz("invalid_datetime")});
		},

		parse_instructor => sub {
			my ($resource, $datetime, $duration) = @_;

			my $span = $dtf->span_d($datetime, $duration);
			my $vacancies = $resources->vacancies($resource, $duration);

			my @result = map { $_->{instructor} }
				grep { $_->{span}->contains($span) } @$vacancies;

			scalar @result ? $result[0] : undef;
		},

		send_instructor_failed => sub {
			$api->sendMessage({
				chat_id => $chat_id, text => lz("instructor_not_found")});
		},

		book => sub {
			my ($resource, $datetime, $duration, $instructor) = @_;

			my $span = $dtf->span_d($datetime, $duration);
			$resources->book($user->{id}, $resource, $span);

			$api->sendMessage({
				chat_id => $chat_id,
				text => lz("booked", $resource, dt($datetime))});
			$instructors->share_contact($instructor, $chat_id);

			$instructors->notify_new_book($instructor, $user, $resource, $span);
		},

		send_refresh => sub {
			$api->sendMessage({
				chat_id => $chat_id,
				text => lz("press_refresh_button"),
				reply_markup => create_one_time_keyboard([lz("refresh")], 1)
			});
		},
	);
}


Google::CalendarAPI::auth(
	"gapi.conf", "fablab61ru\@gmail.com", $jsonconfig->{timezone});


_log_info($sid, "ready to process incoming messages");


my $polling_interval = 1;
Mojo::IOLoop->recurring($polling_interval => sub {
	my $hash = get_last_messages($api);
	while (my ($chat_id, $update) = each(%$hash)) {
		$sid++;

		if (not defined $update
				or not defined $update->{message}
				or not defined $update->{message}->{from}) {
			_log_info($sid, "unknown update - ignored");
		} elsif ($chat_id ne $update->{message}->{from}->{id}) {
			if (defined $update->{message}->{new_chat_participant}
					or defined $update->{message}->{left_chat_participant}) {
				$groups->process($update->{message});
				_log_info($sid, "group message processed");
			} else {
				_log_info($sid, "non-private message ignored");
			}
		} else {
			my $user = $update->{message}->{from};
			_log_info($sid, "new message: " . encode_json($update->{message}));

			if (defined $update->{message}{text}
					and substr($update->{message}{text}, 0, 1) eq "%") {
				# temporary mode for restgram testing
				_log_info($sid, "restgram testing");

				my $phone = substr($update->{message}{text}, 1);
				my $answer = encode_json($restgram->get_full_user_by_phone($phone));
				_log_info($sid, "answer: $answer");

				$api->sendMessage({chat_id => $chat_id, text => $answer});

			} else {
				if (not exists $machines{$chat_id}) {
					$machines{$chat_id} = new_fsm($user, $chat_id);
					_log_info($sid, "finite state machine created");
				}
				$machines{$chat_id}->next($update);
				_log_info($sid, "moved to next state");
			}
		}

		_log_info($sid, "message processing finished");
	}
});

app->start;
