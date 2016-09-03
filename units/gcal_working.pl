#!/usr/bin/env perl

# https://developers.google.com/oauthplayground/

use common::sense;
use Mojo::UserAgent;
use Data::Dumper;

use DateTime;
use DateTime::Duration;
use DateTime::Format::ISO8601;

my $ua = Mojo::UserAgent->new;
my $api_base = 'https://www.googleapis.com/calendar/v3';

my $authorization_code = '4/S1ZBHPm25RQ2vbjavnxGhGKAEMuq_9YBVHIThhlU1Q4';

## Global
my $tokens = {};
$tokens->{access_token} = 'ya29.Ci9TA2zAQV2QQ8fe0Mrdal7ZduYfR7EpO9Dqs_ZBOn_v-QNvZXw4bkseAqtaxJe2AQ';
$tokens->{refresh_token} = '1/SAdB_5pJTnS3oGKz8zFCT6F0oEH8_ZX-JsEsIPj7vOI';

my $api_keys = {};
$api_keys->{client_secret} = 'kW0SHr6L1qeSNuskSmry-2xS';
$api_keys->{client_id} = '689351312936-vgjhug2fu23rtvm8mn5ulqvg3jo12vl4.apps.googleusercontent.com';


# warn Dumper $ua->get('https://www.googleapis.com/calendar/v3/users/me/calendarList' => 
#     { 'Authorization' => 'Bearer '.$tokens->{access_token} } 
# )->res->json;




#warn Dumper DateTime->now;

# warn Dumper add_event($id);
#warn Dumper freebusy($id, '2016-07-26T09:00:00-07:00', '2016-07-26T10:00:00-07:00');


sub get_calendar_id_by_name {
    my $name = shift;
    my $all = get_calendars(); # arr ref
    my @n = grep { $_->{'summary'} eq $name } @$all;
    my $full_id = $n[0]->{id};
    #warn Dumper (split('@', $full_id))[0];
    #return (split('@', $full_id))[0];
    return $full_id;
}

sub get_calendars {
    my @a;
    my %h = (
        'Authorization' => 'Bearer '.$tokens->{access_token}
    );
    my $res = $ua->get($api_base.'/users/me/calendarList' => \%h)->res->json;
    for my $item (@{$res->{items}}) {
        push @a, { map { $_ => $item->{$_} } grep { exists $item->{$_} } qw\id summary\ }; 
    }
    return \@a;
}


sub add_event {
    my $c_id = shift;
    my $r_body = {};
    $r_body->{summary} = 'Pavel Serikov';
    $r_body->{description} = 'test';
    $r_body->{location} = 'FabLab61';
    $r_body->{start}{dateTime} = '2016-07-27T09:00:00-07:00';
    $r_body->{end}{dateTime} = '2016-07-27T10:00:00-07:00';
    $r_body->{start}{timeZone} = $r_body->{start}{timeZone} = 'Europe/Moscow';
    my %h = (
        'Authorization' => 'Bearer '.$tokens->{access_token}
    );
    return $ua->post($api_base.'/calendars/'.$c_id.'/events' => \%h => json => $r_body)->res->json;
}


sub add_event {
    my $c_id = shift;
    my $r_body = {};
    $r_body->{'summary'} = 'Pavel Serikov';
    $r_body->{start}{dateTime} = '2016-07-25T09:00:00-07:00';
    $r_body->{end}{dateTime} = '2016-07-25T10:00:00-07:00';
    $r_body->{start}{timeZone} = $r_body->{start}{timeZone} = 'Europe/Moscow';
    my %h = (
        'Authorization' => 'Bearer '.$tokens->{access_token}
    );
    return $ua->post($api_base.'/calendars/'.$c_id.'/events' => \%h => json => $r_body)->res->json;
}

# Return information about free/busy time of needed calendar
sub freebusy {
    my ($c_id, $dt_start, $dt_end) = @_;
    my $r_body = {};
    $r_body->{'timeMin'} = '2016-07-25T09:00:00-07:00';
    $r_body->{'timeMax'} = '2016-07-25T10:00:00-07:00';
    $r_body->{'timeZone'} = 'Europe/Moscow';
    $r_body->{'items'} = [{ 'id' => $c_id }];

    my %h = (
        'Authorization' => 'Bearer '.$tokens->{access_token}
    );
    return $ua->post($api_base.'/freeBusy' => \%h => json => $r_body)->res->json;
};










# warn Dumper new_access_token($authorization_code);



# warn Dumper new_access_token($api_keys->{client_secret}, $tokens->{refresh_token});

# my %hash = (
#         'client_id' => $api_keys->{client_id},
#         'client_secret' => $api_keys->{client_secret},
#         'grant_type' => 'refresh_token',
#         'refresh_token' => $tokens->{refresh_token}
# );

# warn Dumper $ua->post('https://www.googleapis.com/oauth2/v3/token' => form => \%hash)->res->json;



sub new_access_token {
    my $auth_code = shift;
    my $hash = {};
    $hash->{code} = $auth_code;
    $hash->{redirect_uri} = 'https://developers.google.com/oauthplayground';
    $hash->{client_id} = $api_keys->{client_id};
    $hash->{client_secret} = $api_keys->{client_secret};
    $hash->{grant_type} = 'authorization_code';
    my $res = $ua->post('https://www.googleapis.com/oauth2/v4/token' => form => $hash)->res->json;
    return $res;
}



warn Dumper get_calendars();
my $id = get_calendar_id_by_name('Lasersaur');
warn $id;