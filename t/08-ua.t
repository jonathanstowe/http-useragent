use v6;
use HTTP::UserAgent;
use HTTP::UserAgent::Common;
use Test;

plan 10;

# new
my $ua = HTTP::UserAgent.new;
nok $ua.useragent, 'new 1/3';

$ua = HTTP::UserAgent.new(:useragent('test'));
is $ua.useragent, 'test', 'new 2/3';

my $newua = get-ua('chrome_linux');
$ua = HTTP::UserAgent.new(:useragent('chrome_linux'));
is $ua.useragent, $newua, 'new 3/3';

# user agent
is $ua.get('http://ua.offensivecoder.com/').content, "$newua\n", 'useragent 1/1';

# get
my $response = $ua.get('filip.sergot.pl/');
ok $response, 'get 1/3';
isa_ok $response, HTTP::Response, 'get 2/3';
ok $response.is-success, 'get 3/3';

# non-ascii encodings (github issue #35)
lives_ok { HTTP::UserAgent.new.get('http://www.baidu.com') }, 'Lived through gb2312 encoding';

subtest {
   my $ua = HTTP::UserAgent.new;
   my $req = HTTP::Request.new(GET => 'http://example.com');
   dies_ok { $ua.get-connection }, "get-connection no request";
   ok my $conn = $ua.get-connection($req), "get-connection with request"; 
   ok $conn.does(IO::Socket), "connection does IO::Socket";
   is $conn.host, "example.com", "got the right host";
   is $conn.port, 80, "got the right port";
   $req = HTTP::Request.new(GET => 'http://example.com:443');
   ok $conn = $ua.get-connection($req), "get-connection with request (non-default port"; 
   is $conn.host, "example.com", "got the right host";
   is $conn.port, 443, "got the right port";

}, "get-connection";

subtest {
   my $ua = HTTP::UserAgent.new;
   $ua.auth('foo','bar');
   my $req = HTTP::Request.new(GET => 'http://example.com');
   ok !$req.header.field('Authorization'), "got no authorization header";
   ok $ua.process-request($req), "process request";
   ok $req.header.field('Authorization'), "got an auth header now";
   is ~$req.header.field('Authorization'), $ua.encode-auth, "and it is the right value";
}, "process-request";
