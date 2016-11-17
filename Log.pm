package Log;

use strict;
use warnings;

use Log::Any ();
use Log::Any::Adapter ('Stdout');
use Log::Any::For::Std;

my $sid = 0;
sub incsid {
	$sid++;
}

sub new {
	my ($class, $category) = @_;
	my $log = Log::Any->get_logger(category => $category // "general");
	my $self = {log => $log};
	bless $self, $class;
}

sub infof {
	my ($self, $message, @params) = @_;
	$self->{log}->infof("[$sid] " . $message, @params);
}

1;
