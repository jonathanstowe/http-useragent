use v6;

use Test;

use HTTP::Response;

plan 15;

# new
my $r = HTTP::Response.new(200, a => 'a');

isa-ok $r, HTTP::Response, 'new 1/3';
isa-ok $r, HTTP::Message, 'new 2/3';
is $r.field('a'), 'a', 'new 3/3';

# field
$r.field(h => 'h');
is $r.field('h'), 'h', 'field 1/2';
$r.field(h => 'abc');
is $r.field('h'), 'abc', 'field 2/2';

# status-line
is $r.status-line, '200 OK', 'status-line 1/1';

# is-success
ok $r.is-success, 'is-success 1/2';
$r.set-code(404);
ok !$r.is-success, 'is-success  2/2';

# set-code
is $r.status-line, '404 Not Found', 'set-code 1/1';

# parse
my $res = "HTTP/1.1 200 OK\r\nHost: hoscik\r\n\r\ncontent\r\n";
$r = HTTP::Response.new.parse($res);
is $r.Str, $res, 'parse - Str 1/4';
is $r.content, 'content', 'parse - content 2/4';
is $r.status-line, '200 OK', 'parse - status-line 3/4';
is $r.protocol, 'HTTP/1.1', 'parse - protocol 4/4';

# location

subtest {
   my $r = HTTP::Response.new;
   ok !$r.location.defined, "location - not defined";
   $r.header.field(Location => 'http://example.com');
   is $r.location, 'http://example.com', "location - set right";

}, "location";

# next-request

subtest {
   my $r = HTTP::Response.new;
   ok !$r.next-request.defined, "next-request location not defined";
   $r.header.field(Location => 'http://example.com');
   ok !$r.next-request.defined, "next-request location defined but no request";
   my $req = HTTP::Request.new;
   $req.header.field(Accept => 'application/json');
   $r.request = $req;
   ok my $nr = $r.next-request, "next-request - request defined";
   ok $nr.defined, "and the request is defined";
   isa_ok $nr, HTTP::Request, 'next-request returns an HTTP::Request';
   is $nr.url, 'http://example.com', "the new request url is correct";
   is ~$nr.header.field('Accept'), 'application/json', "and it has the header field from the original request";
}, "next-request";
