#!/usr/bin/env perl

# sudo cpan Mojolicious::Plugin::OAuth2


use Mojolicious::Lite;
use Data::Dumper;

plugin "OAuth2" => {
  google => {
    key => "397141148797-hnbm3cl49buonecqa982iamefll5bpn9.apps.googleusercontent.com",
      secret => "LBL2b797n5ql849XN8cECWw9"
  },
};

get "/" => sub {
  shift->render(template => 'oauth');
};


get "/connect" => sub {
  my $c = shift;
  $c->delay(
    sub {
      my $delay = shift;
      my $args = {redirect_uri => $c->url_for('connect')->userinfo(undef)->to_abs};
      # my $args = { redirect_uri => 'http://telebook.serikov.xyz/connect' };
      app->log->info("redirect_uri: ".$args->{redirect_uri});
      $c->oauth2->get_token(google => $args, $delay->begin);
    },
    sub {
      my ($delay, $err, $data) = @_;
      app->log->info("Returned data:".Dumper $data);
      return $c->render("result", error => $err) unless $data->{access_token};
      return $c->render("result", error => $err, data => $data);
    },
  );
};


app->start;

__DATA__


@@ oauth.html.ep
Click here to log in:
<%= link_to "Connect!", $c->oauth2->auth_url("google", scope => "https://www.googleapis.com/auth/calendar", redirect_uri => "http://fablab61.ru:3008" ) %>


@@ result.html.ep

Error: <%= $error %><br>
access_token:<%= $data->{access_token} %><br>
authorization_code:<%= $data->{authorization_code} %><br>
