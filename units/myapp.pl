#!/usr/bin/env perl
use Mojolicious::Lite;

plugin "OAuth2" => {
    google => {
      key => "397141148797-hnbm3cl49buonecqa982iamefll5bpn9.apps.googleusercontent.com",
      secret => "LBL2b797n5ql849XN8cECWw9",
    },
  };

get '/' => sub {
  my $c = shift;
    $c->delay(
      sub {
        my $delay = shift;
        my $args = {redirect_uri => $c->url_for('/')->userinfo(undef)->to_abs};
        $c->oauth2->get_token(google => $args, $delay->begin);
      },
      sub {
        my ($delay, $err, $data) = @_;
        return $c->render("/", error => $err) unless $data->{access_token};
        return $c->session(token => $c->redirect_to('profile'));
      },
    );
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<h1>Welcome to the Mojolicious real-time web framework!</h1>
To learn more, you can browse through the documentation
<%= link_to 'here' => '/perldoc' %>.

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
