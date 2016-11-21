#!/usr/bin/env perl

package BookingBot;

use common::sense;
use File::Basename qw(dirname);
use Mojolicious::Lite;

use Contacts;
use DateTimeFactory;
use FSM;
use Google;
use Groups;
use Instructors;
use Localization qw(lz dt);
use Log;
use Resources;
use Telegram;

$| = 1; # disable buffering

my $jsonconfig = plugin "JSONConfig";

DateTimeFactory::set_default_timezone($jsonconfig->{timezone});
Localization::set_language($jsonconfig->{language});

my $api = Telegram::BotAPI->new($jsonconfig->{token});
my $contacts = Contacts->new($api);
my $dtf = DateTimeFactory->new;
my $groups = Groups->new($api->my_id);
my $instructors = Instructors->new(
	$api, $contacts, $groups, $jsonconfig->{instructors});
my $resources = Resources->new($jsonconfig->{resources});
my $log = Log->new();
my %machines = ();

sub new_fsm {
	my ($user, $chat_id) = @_;

	FSM->new(
		send_start_message => sub {
			$api->send_message({chat_id => $chat_id, text => lz("start")});
		},

		send_contact_message => sub {
			$api->send_message({chat_id => $chat_id, text => lz("contact")});
		},

		save_contact => sub {
			my ($contact) = @_;
			if (defined $contact) {
				$contacts->add($user->{id}, $contact);
				1;
			}
		},

		send_contact_failed => sub {
			$api->send_message({
					chat_id => $chat_id, text => lz("invalid_contact")});
		},

		send_begin_message => sub {
			$api->send_message({chat_id => $chat_id, text => lz("begin")});
		},

		send_resources => sub {
			my @durations = sort { $a <=> $b }
				values %{$jsonconfig->{durations}};
			my $min = $dtf->dur(minutes => shift @durations);

			my @keyboard = grep {
				scalar @{$resources->vacancies($_, $min)} > 0;
			} @{$resources->names};

			if (scalar @keyboard > 0) {
				$api->send_keyboard({
					chat_id => $chat_id,
					text => lz("select_resource"),
					keyboard => \@keyboard
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
			$api->send_message({
				chat_id => $chat_id, text => lz("resource_not_found")});
		},

		send_resource_failed => sub {
			$api->send_message({
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
				$api->send_keyboard({
					chat_id => $chat_id,
					text => lz("select_duration"),
					keyboard => \@keyboard
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
			$api->send_message({
				chat_id => $chat_id, text => lz("duration_not_found")});
		},

		send_duration_failed => sub {
			$api->send_message({
				chat_id => $chat_id, text => lz("invalid_duration")});
		},

		send_datetime_selector => sub {
			my ($resource, $duration) = @_;

			my $vacancies = $resources->vacancies($resource, $duration);
			my @keyboard = map { dt($_->{span}->start) } @$vacancies;

			$api->send_keyboard({
				chat_id => $chat_id,
				text => lz("select_datetime"),
				keyboard => \@keyboard
			});
		},

		parse_datetime => sub {
			my ($inputstr) = @_;
			$dtf->parse($inputstr);
		},

		send_datetime_failed => sub {
			$api->send_message({
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
			$api->send_message({
				chat_id => $chat_id, text => lz("instructor_not_found")});
		},

		book => sub {
			my ($resource, $datetime, $duration, $instructor) = @_;

			my $span = $dtf->span_d($datetime, $duration);
			$resources->book(lz("booked_by", $contacts->fullname($user->{id})),
				$resource, $span);

			$api->send_message({
				chat_id => $chat_id,
				text => lz("booked", $resource, dt($datetime))});

			if ($instructors->exists($instructor)) {
				$instructors->share_contact($instructor, $chat_id);
				$instructors->notify_instructor(
					$instructor, $user, $resource, $span);
			}
			$instructors->notify_groups($instructor, $user, $resource, $span);
		},

		send_refresh => sub {
			$api->send_keyboard({
				chat_id => $chat_id,
				text => lz("press_refresh_button"),
				keyboard => [lz("refresh")]
			});
		},
	);
}

Google::CalendarAPI::auth(dirname(__FILE__) . "/gapi.conf", "fablab61ru\@gmail.com");


$log->infof("ready to process incoming messages");

while (1) {
	my $hash = $api->last_messages();
	while (my ($chat_id, $update) = each(%$hash)) {
		Log::incsid;

		if (not defined $update
				or not defined $update->{message}
				or not defined $update->{message}->{from}) {
			$log->infof("unknown update - ignored");
		} elsif ($chat_id ne $update->{message}->{from}->{id}) {
			if (defined $update->{message}->{new_chat_participant}
					or defined $update->{message}->{left_chat_participant}) {
				$groups->process($update->{message});
				$log->infof("group message processed");
			} else {
				$log->infof("non-private message ignored");
			}
		} else {
			my $user = $update->{message}->{from};
			$log->infof("new message: %s", $update->{message});

			if (not exists $machines{$chat_id}) {
				$machines{$chat_id} = new_fsm($user, $chat_id);
				$log->infof("finite state machine created");
			}

			$machines{$chat_id}->next($update);
			$log->infof("moved to next state");
		}

		$log->infof("message processing finished");
	}

	sleep 1;
}
