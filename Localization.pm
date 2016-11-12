package Localization;

use strict;
use warnings;
use utf8;

use parent ("Exporter");

use Utils;

my %strings = (
	"English" => {
		"welcome"                   => "Hello! I am FabLab61 booking bot",
		"select_resource"           => "Select tool",
		"invalid_resource"          => "Invalid tool name (typo?)",
		"select_duration"           => "How long will you use the tool?",
		"enter_date"                => "Enter date (example: 1 Jan 2017 12:00)",
		"invalid_date_format"       => "Invalid date format",
		"booked"                    => "You have booked %s at %s",

		"30_min"                    => "30 minutes",
		"1_hour"                    => "1 hour",
		"2_hours"                   => "2 hours",
		"3_hours"                   => "3 hours",
	},

	"Russian" => {
		"welcome"                   => "Привет! Я бот для бронирования оборудования FabLab61",
		"select_resource"           => "Выбери оборудование",
		"invalid_resource"          => "Нет такого оборудования (опечатка?)",
		"enter_date"                => "Введи дату (в формате 1 Jan 2017 12:00)",
		"invalid_date_format"       => "Неверный формат даты",
		"booked"                    => "Оборудование %s забронировано на дату %s",
	},
);

sub languages {
	my @result = keys %strings;
	\@result;
}

my $fallback = "English";
my $language = $fallback;

sub set_language {
	my ($new_language) = @_;

	my $result = Utils::contains(languages, $new_language);
	if ($result) {
		$language = $new_language;
	}

	$result;
}

sub lz {
	my ($key, @params) = @_;

	sub _keys {
		my ($language) = @_;
		my @result = keys %{$strings{$language}};
		\@result;
	};

	if (Utils::contains(_keys($language), $key)) {
		sprintf($strings{$language}{$key}, @params);
	} elsif (Utils::contains(_keys($fallback), $key)) {
		sprintf($strings{$fallback}{$key}, @params);
	} else {
		$key;
	}
}

our @EXPORT_OK = ("lz");

1;
