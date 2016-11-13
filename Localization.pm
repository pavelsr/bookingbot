package Localization;

use strict;
use warnings;
use utf8;

use parent ("Exporter");

my %strings = (
	"English" => {
		"datetime_format"           => "%%d %%b %%H:%%M",

		"welcome"                   => "Hello! I am FabLab61 booking bot",
		"select_resource"           => "Select tool",
		"invalid_resource"          => "Invalid tool name (typo?)",
		"select_duration"           => "How long will you use the tool?",
		"select_datetime"           => "Select convenient time",
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
		"select_datetime"           => "Выбери подходящее время",
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

	my $languages_ = languages;
	my $result = grep { $_ eq $new_language } @$languages_;
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

	if (grep { $_ eq $key } keys %{$strings{$language}}) {
		sprintf($strings{$language}{$key}, @params);
	} elsif (grep { $_ eq $key } keys %{$strings{$fallback}}) {
		sprintf($strings{$fallback}{$key}, @params);
	} else {
		$key;
	}
}

sub dt {
	my ($datetime) = @_;
	$datetime->strftime(lz("datetime_format"));
}

our @EXPORT_OK = ("lz", "dt");

1;
