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

my $jsonconfig = plugin 'JSONConfig';

BEGIN { $ENV{TELEGRAM_BOTAPI_DEBUG}=1 };

my $api = WWW::Telegram::BotAPI->new (
    token => '222684756:AAHSkWGC101ooGT3UYSYxofC8x3BD1PT5po'
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
use JSON qw(encode_json);

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

Mojo::IOLoop->recurring($polling_interval => sub {
	my $hash = get_last_messages($api); # last message for polling period for each chat_id. keys = chat_id


		while ( my ($chat_id, $update) = each(%$hash) ) {   # Answer to all connected clients and store history. Triggers only if there is a new message

			app->log->info("New message: ".$update->{message}{text}." from chat_id: ".$update->{message}{chat}{id});

			# if (!($screens->is_last_screen)) {


			# if (!($screens->is_first_screen)) {
			# 	$api->sendMessage({ chat_id => $chat_id, text => $screens->get_answ_by_key($update->{message}{text}) });
			# } else {
			# 	app->log->info("First screen!");
			# }
			
			$screens->find_screen($update->{message}{text}); # hash of undef. update pointer to current screen

			# If command isn't mathed any button
			# if ($screens->prev_screen->{key} ne $update->{message}{text}) {
			# 	$api->sendMessage({ chat_id => $chat_id, text => "Пожалуйста, выберите вариант из предложенных" });
			# }

				#	warn "Find screen:".Dumper $screens->current->{name};
				# or use $screens->current;

			if (substr($update->{message}{text}, 0, 1) eq '%') {
				# temporary mode for restgram testing

				my $phone = substr($update->{message}{text}, 1);
				$api->sendMessage({chat_id => $chat_id, text => encode_json($restgram->get_full_user_by_phone($phone))});
			} elsif (defined $screens->current) {

						if ($screens->is_first_screen) {
							$sessions->update_sessions($chat_id, $update); 
						} else {
							$sessions->update_sessions($chat_id, $update, { reply_to_screen => $screens->current->{name} }); 
						}

						app->log->info('Showing screen which name is : '.$screens->current->{name});
						my $btns = extract_keys($screens->current);
						warn "buttons:".Dumper $btns;
						warn Dumper create_one_time_keyboard($btns);  # return json
						$api->sendMessage({ chat_id => $chat_id, text => "Next screen...", reply_markup => create_one_time_keyboard($btns) });
					
			} else {

				app->log->info('Cant found next screen. Check your JSONconfig');
				$api->sendMessage({ chat_id => $chat_id, text => "No screen found/Команда не распознана" });
			}

			# } else {
			# 	$api->sendMessage({ chat_id => $chat_id, text => "Last screen. Serializing data..." });
			# }

		}


});

app->start;
