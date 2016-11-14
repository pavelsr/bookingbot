Telegram bot that helps FabLab to create a schedule

GUI from web browser - http://booking.fablab61.ru/

[Developers guide](https://bitbucket.org/serikov/fab_booking_bot/wiki/Developers%20Guide)

# Build and run

## Requirements

1. Docker 1.6.2 or above.
1. Google Authenticate file. Check [this instruction](https://bitbucket.org/serikov/google-apis-perl) to create it.

## Steps

1. Clone the repository.
1. Put Google Authenticate file into repo dir. Rename it to `gapi.conf`.
1. Open `bot.pl` in text editor and replace Telegram token with yours.
1. Run `docker_build_and_run.sh` (you have to be `root` or member of `docker` group). It will take some time to download Docker images and Perl modules.

# Configuration

Configuration file named `bot.json` and has following structure (comments separated with '#'):

```
{
	"timezone": "Europe/Moscow",           # Bot time zone.

	"resources": {
		"CTC 3D printer": {                # Human-readable name of resource.
			"calendar": "primary"          # Resource calendar id ("primary" for primary account calendar).
		},
	},

	"durations": {                         # Available booking durations in form
		"30_min": 30,                      # LANGUAGE_ID => MINUTES.
		"1_hour": 60,
		"2_hours": 120,
		"3_hours": 180
	},

	"instructors": {                       # List of registered instructors.
		"email@example.com": {             # Human-readable instructor id (username, email - whatever).
			"id": "123456789",             # Instructor's Telegram user id.
			"phone_number": "12345678901", # Instructor's phone number
			"first_name": "Neil",          # and name.
			"last_name": "Gershenfeld"
		}
	}
}
```
