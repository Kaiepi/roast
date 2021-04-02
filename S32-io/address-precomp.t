use v6;
use Test;

plan 3;

cmp-ok (BEGIN IO::Address::IPv4('127.0.0.1:80')), &[===], IO::Address::IPv4('127.0.0.1:80'),
       'IPv4 addresses precomp OK';
cmp-ok (BEGIN IO::Address::IPv6('[::1%1]:80')), &[===], IO::Address::IPv6('[::1%1]:80'),
       'IPv6 addresses precomp OK';
cmp-ok (BEGIN IO::Address::UNIX('/')), &[===], IO::Address::UNIX('/'),
       'UNIX socket addressses precomp OK';
