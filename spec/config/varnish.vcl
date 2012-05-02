backend default {
  .host = "127.0.0.1";
  .port = "3000";
}

sub vcl_recv {
  set req.backend = default;
  unset req.http.Cookie;
  set req.grace = 30m;
}

sub vcl_fetch {
  unset beresp.http.Set-Cookie;
  set beresp.grace = 30m;
}
