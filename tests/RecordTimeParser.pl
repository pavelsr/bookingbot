use strict;
use warnings;

use Test::More tests => 1;

use lib "..";
use RecordTimeParser;

subtest "_tokenize (russian)" => sub {
	Localization::set_language("Russian");

	my @data = ({
			"input" => "сегодня с 10:45 до 12",
			"expected" => {
				day			=> "сегодня",
				preposition	=> "с",
				hour1		=> 10,
				minute1		=> 45,
				hour2		=> 12,
				minute2		=> 0,
			},
		}, {
			"input" => "завтра с 10 до 12",
			"expected" => {
				day			=> "завтра",
				preposition	=> "с",
				hour1		=> 10,
				minute1		=> 0,
				hour2		=> 12,
				minute2		=> 0,
			},
		}, {
			"input" =>	"в пятницу с 15:20",
			"expected" => {
				day			=> "пятницу",
				preposition	=> "с",
				hour1		=> 15,
				minute1		=> 20,
				hour2		=> 0,
				minute2		=> 0,
			},
		}, {
			"input" =>	"в чт после 18",
			"expected" => {
				day			=> "чт",
				preposition	=> "после",
				hour1		=> 18,
				minute1		=> 0,
				hour2		=> 0,
				minute2		=> 0,
			},
		}, {
			"input" =>	"в сб до 13",
			"expected" => {
				day			=> "сб",
				preposition	=> "до",
				hour1		=> 13,
				minute1		=> 0,
				hour2		=> 0,
				minute2		=> 0,
			},
		}, {
			"input" =>	"пн в 8",
			"expected" => {
				day			=> "пн",
				preposition	=> "в",
				hour1		=> 8,
				minute1		=> 0,
				hour2		=> 0,
				minute2		=> 0,
			},
		},
	);

	foreach my $record (@data) {
		is_deeply(
			RecordTimeParser::_tokenize($record->{input}),
			$record->{expected},
			$record->{input});
	}
};
