package Utils;

use strict;
use warnings;

sub contains {
	my ($array, $value) = @_;
	defined $value and grep { $_ eq $value } @$array;
}

1;
