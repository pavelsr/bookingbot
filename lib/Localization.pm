package Localization;

use strict;
use warnings;
use utf8;

use parent ("Exporter");

my %strings = (
	"English" => {
		"na"                                  => "N/A",

		"datetime_format"                     => "%%d %%b %%H:%%M",
		"contact_format"                      => "▶ %s %s\n📞 %s",

		"span_regexp"                         => qr/(?:[^\d\s]+\s+)?([^\d\s,]+)(?:(?:\s*,\s*)|(?:\s+))([^\d\s]+)\s+(\d+)(?:[:.-](\d+))?(?:\s+[^\d\s]+\s+(\d+)(?:[:.-](\d+))?)?/i,
		"today"                               => "today",
		"tomorrow"                            => "tomorrow",

		"monday_full"                         => "monday",
		"tuesday_full"                        => "tuesday",
		"wednesday_full"                      => "wednesday",
		"thursday_full"                       => "thursday",
		"friday_full"                         => "friday",
		"saturday_full"                       => "saturday",
		"sunday_full"                         => "sunday",

		"monday_short"                        => "mon",
		"tuesday_short"                       => "tue",
		"wednesday_short"                     => "wed",
		"thursday_short"                      => "thu",
		"friday_short"                        => "fri",
		"saturday_short"                      => "sat",
		"sunday_short"                        => "sun",

		"weekday_preposition"                 => "on",
		"from_preposition"                    => "from",
		"to_preposition"                      => "to",

		"30_min"                              => "30 minutes",
		"1_hour"                              => "1 hour",
		"2_hours"                             => "2 hours",
		"3_hours"                             => "3 hours",

		"start"                               => "Hello! I am FabLab61 booking bot",
		"contact"                             => "Share your contact with me in order to book tools",
		"invalid_contact"                     => "This is not information I need. Try again",
		"begin"                               => "OK. Let's begin!",
		"select_resource"                     => "Select tool for booking",
		"resource_not_found"                  => "I can't found free tools for now, sorry. Try again later",
		"invalid_resource"                    => "This is not information I need. Try again",
		"select_duration"                     => "OK. How long will you use the tool?",
		"duration_not_found"                  => "I can't found free vacancies for this tool, sorry. Try again later",
		"invalid_duration"                    => "This is not information I need. Try again",
		"select_datetime"                     => "OK. Select convenient time",
		"invalid_datetime"                    => "This is not information I need. Try again",
		"instructor_not_found"                => "I can't found an instructor for you (looks like this time has been booked already). Please, select another time",
		"booked"                              => "OK, done. I have booked %s for you at %s",
		"booked_by"                           => "Booked by %s",
		"instructor_contact"                  => "Here is your instructor contact:",

		"press_refresh_button"                => "Press the button to refresh data",
		"refresh"                             => "Refresh",

		"instructor_start"                    => "Hello! I am FabLab61 booking bot",
		"instructor_cancel_operation"         => "❌ Cancel operation",
		"instructor_operation_cancelled"      => "Operation cancelled",
		"instructor_menu"                     => "What can I do for you?",
		"instructor_show_schedule"            => "📒 Show my schedule",
		"instructor_add_record"               => "➕ Add record to the schedule",
		"instructor_schedule"                 => "OK, I am going to send you the schedule in a moment",
		"instructor_record_time"              => "Enter time when you are available",
		"instructor_new_book"                 => "Hi! I have received new book record for you, here is what I have:\nResource: %s\nBooked from %s to %s\nI will send you the user contact in a moment\nYour contact has been sent to the user already\nHave a nice day! 😊",

		"group_new_book"                      => "Hi guys! I have received new book record for instructor %s (%s), here is what I have:\nResource: %s\nBooked from %s to %s\nI will post here the user contact in a moment\nThe instructor's contact has been sent to the user already\nHave a nice day! 😊",
		"group_new_book_fallback"             => "Hi guys! I have received new book record, here is what I have:\nResource: %s\nBooked from %s to %s\nI will post here the user contact in a moment\nHave a nice day! 😊",
	},

	"Russian" => {
		"na"                                  => "Н/Д",

		"today"                               => "сегодня",
		"tomorrow"                            => "завтра",

		"monday_full"                         => "понедельник",
		"tuesday_full"                        => "вторник",
		"wednesday_full"                      => "среда",
		"thursday_full"                       => "четверг",
		"friday_full"                         => "пятница",
		"saturday_full"                       => "суббота",
		"sunday_full"                         => "воскресенье",

		"monday_short"                        => "пн",
		"tuesday_short"                       => "вт",
		"wednesday_short"                     => "ср",
		"thursday_short"                      => "чт",
		"friday_short"                        => "пт",
		"saturday_short"                      => "сб",
		"sunday_short"                        => "вс",

		"weekday_preposition"                 => "в",
		"from_preposition"                    => "с",
		"to_preposition"                      => "до",

		"30_min"                              => "30 минут",
		"1_hour"                              => "1 час",
		"2_hours"                             => "2 часа",
		"3_hours"                             => "3 часа",

		"start"                               => "Привет! Я бот для бронирования оборудования FabLab61",
		"contact"                             => "Пришли мне свои контакты, чтобы получить доступ к бронированию",
		"invalid_contact"                     => "Это не то, что мне нужно. Попробуй ещё раз",
		"begin"                               => "Хорошо. Приступим!",
		"select_resource"                     => "Выбери оборудование для бронирования",
		"resource_not_found"                  => "Я не нашёл свободного оборудования на данный момент, извини. Попробуй позже",
		"invalid_resource"                    => "Это не то, что мне нужно. Попробуй ещё раз",
		"select_duration"                     => "Понял. Сколько планируешь работать с оборудованием?",
		"duration_not_found"                  => "Я не нашёл свободного времени для данного оборудования, извини. Попробуй позже",
		"invalid_duration"                    => "Это не то, что мне нужно. Попробуй ещё раз",
		"select_datetime"                     => "Понял. Выбери подходящее время",
		"invalid_datetime"                    => "Это не то, что мне нужно. Попробуй ещё раз",
		"instructor_not_found"                => "Я не смог найти инструктора для тебя (возможно, выбранное тобой время уже заняли). Выбери другое время, пожалуйста",
		"booked"                              => "Отлично, я забронировал для тебя %s на дату %s",
		"booked_by"                           => "Забронировал %s",
		"instructor_contact"                  => "Вот контакт твоего инструктора:",

		"press_refresh_button"                => "Нажми кнопку чтобы обновить информацию",
		"refresh"                             => "Обновить",

		"instructor_new_book"                 => "Привет! Я получил новую заявку на бронирование твоего оборудования. Вот информация, которая у меня есть:\nОборудование: %s\nВремя брони: с %s до %s\nСейчас я пришлю контакты клиента\nТвои контакты уже отправлены\nХорошего дня! 😊",

		"group_new_book"                      => "Всем привет! Я получил новую заявку на бронирование для инструктора %s (%s). Вот что я узнал:\nОборудование: %s\nВремя брони: с %s до %s\nСейчас я пришлю контакты клиента\nКонтакты инструктора уже отправлены клиенту\nВсем хорошего дня! 😊",
		"group_new_book_fallback"             => "Всем привет! Я получил новую заявку на бронирование. Вот что я узнал:\nОборудование: %s\nВремя брони: с %s до %s\nСейчас я пришлю контакты клиента\nВсем хорошего дня! 😊",
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
	my $result = defined $new_language and
		grep { $_ eq $new_language } @$languages_;
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
