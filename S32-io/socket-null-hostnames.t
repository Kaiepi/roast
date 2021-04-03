use v6.e.PREVIEW;
use Test;

plan 2;

lives-ok {
    my IO::Socket::INET:D $server .= listen: 0;
    my IO::Socket::INET:D $client .= connect: $server.local-address.port;
    $server.accept.close;
    LEAVE $client.close with $client;
    LEAVE $server.close with $server;
}, 'can connect to servers through null hostnames synchronously';

lives-ok {
    my IO::Socket::Async::ListenSocket:D $server = IO::Socket::Async.listen(0).tap(*.close);
    my IO::Socket::Async:D               $client = await IO::Socket::Async.connect: $server.local-address.port;
    LEAVE $client.close with $client;
    LEAVE $server.close;
}, 'can connect to servers through null hostnames asynchronously';

# vim: expandtab shiftwidth=4
