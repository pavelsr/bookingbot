package Localization;

use strict;
use warnings;
use utf8;

use parent ("Exporter");

my %strings = (
	"English" => {
		"na"                        => "N/A",

		"datetime_format"           => "%%d %%b %%H:%%M",

		"30_min"                    => "30 minutes",
		"1_hour"                    => "1 hour",
		"2_hours"                   => "2 hours",
		"3_hours"                   => "3 hours",

		"welcome"                   => "Hello! I am FabLab61 booking bot",
		"select_resource"           => "OK, let's begin. Select tool for booking",
		"invalid_resource"          => "I can't parse your message, sorry. Try again",
		"select_duration"           => "OK. How long will you use the tool?",
		"invalid_duration"          => "I can't parse your message, sorry. Try again",
		"select_datetime"           => "OK. Select convenient time",
		"invalid_datetime"          => "I can't parse your message, sorry. Try again",
		"instructor_not_found"      => "I can't found an instructor for you (looks like this time has been booked already). Please, select another time",
		"booked"                    => "OK, done. I have booked %s for you at %s.\nHere is your instructor contact:",

		"instructor_new_book"       => "Hi! I have received new book record for you, here is what I have:\nResource: %s\nStart time: %s\nEnd time: %s\nUser ID: %s\nFirst name: %s\nLast name: %s\nUsername: %s.\nYour contact has been sent to the user.\nHave a nice day! 😊",
		"chat_new_book"             => "Hi guys! I have received new book record for %s, here is what I have:\nResource: %s\nStart time: %s\nEnd time: %s\nUser ID: %s\nFirst name: %s\nLast name: %s\nUsername: %s.\nThe instructor contact has been sent to the user.\nHave a nice day! 😊",
	},

	"Russian" => {
		"na"                        => "Н/Д",

		"30_min"                    => "30 минут",
		"1_hour"                    => "1 час",
		"2_hours"                   => "2 часа",
		"3_hours"                   => "3 часа",

		"welcome"                   => "Привет! Я бот для бронирования оборудования FabLab61",
		"select_resource"           => "Давай начнём. Выбери оборудование для бронирования",
		"invalid_resource"          => "Я ничего не разобрал, извини. Попробуй ещё раз",
		"select_duration"           => "Понял. Сколько планируешь работать с оборудованием?",
		"invalid_duration"          => "Я ничего не разобрал, извини. Попробуй ещё раз",
		"select_datetime"           => "Понял. Выбери подходящее время",
		"invalid_datetime"          => "Я ничего не разобрал, извини. Попробуй ещё раз",
		"instructor_not_found"      => "Я не смог найти инструктора для тебя (возможно, выбранное тобой время уже заняли). Выбери другое время, пожалуйста",
		"booked"                    => "Отлично, я забронировал для тебя %s на дату %s, вот контакт твоего инструктора:",

		"instructor_new_book"       => "Привет! Я получил новую заявку на бронирование твоего оборудования. Вот информация, которая у меня есть:\nОборудование: %s\nВремя брони: с %s до %s\nID пользователя: %s\nИмя: %s\nФамилия: %s\nИмя в Telegram: %s\nТвои контакты я уже отправил клиенту.\nХорошего дня! 😊",
		"chat_new_book"             => "Всем привет! Я получил новую заявку на бронирование для инструктора %s. Вот информация, которая у меня есть:\nОборудование: %s\nВремя брони: с %s до %s\nID пользователя: %s\nИмя: %s\nФамилия: %s\nИмя в Telegram: %s\nКонтакты инструктора я уже отправил клиенту.\nВсем хорошего дня! 😊",
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
