#!/usr/bin/env perl
package BookingBot;

# ABSTRACT: Telegram booking bot

use common::sense;
use FSMFactory;
use Google;
use Groups;
use Localization ();
use Log;
use Telegram;

$| = 1; # disable buffering

=method new

my $bot = BookingBot->new({ config_file => '/home/test/config.json' });

=cut

sub new {
  my ($class, $params) = @_;
  my $h = {};
  if ($params->{config_file}) {  # $params->{config_file} must be abs path
        $h->{cnf_json} = Config::JSON->new($params->{config_file}); # assume that file is valid
        DateTimeFactory::set_default_timezone($h->{cnf_json}->get('timezone'));
		Localization::set_language($h->{cnf_json}->get('language'));
		$h->{telegram_api} = Telegram::BotAPI->new($h->{cnf_json}->get('token'));
		$h->{update_interval_ms} = $h->{cnf_json}->get('update_interval_ms') || 1 ;
		$h->{groups} = Groups->new($h->{telegram_api}->my_id);
		$h->{fsmfactory} = FSMFactory->new($h->{telegram_api}, $h->{groups}, $h->{cnf_json});
		$h->{log} = Log->new();
		Google::CalendarAPI::auth($params->{config_file}, "fablab61ru\@gmail.com");
		$h->{machines} = {};
  } else {
        die 'no json file specified!';
  };
  return bless $h, $class;
}

sub run {
	my $self = shift;
	$self->{log}->infof("ready to process incoming messages");

	while (1) {
		my $hash = $self->{telegram_api}->last_messages();
		while (my ($chat_id, $update) = each(%$hash)) {
			Log::incsid;

			if (not defined $update
					or not defined $update->{message}
					or not defined $update->{message}->{from}) {
				$self->{log}->infof("unknown update - ignored");
			} elsif ($chat_id ne $update->{message}->{from}->{id}) {
				if (defined $update->{message}->{new_chat_participant}
						or defined $update->{message}->{left_chat_participant}) {
					$self->{groups}->process($update->{message});
					$self->{log}->infof("group message processed");
				} else {
					$self->{log}->infof("non-private message ignored");
				}
			} else {
				my $user = $update->{message}->{from};
				$self->{log}->infof("new message: %s", $update->{message});

				if (not exists $self->{machines}{$chat_id}) {
					$self->{machines}{$chat_id} = $self->{fsmfactory}->create($user, $chat_id);
					$self->{log}->infof("finite state machine created");
				}

				$self->{machines}{$chat_id}->next($update);
				$self->{log}->infof("moved to next state");
			}

			$self->{log}->infof("message processing finished");
		}

		sleep $self->{update_interval_ms};
	}

}