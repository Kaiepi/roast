use v6;
use Test;

# https://github.com/Raku/old-issue-tracker/issues/5960

plan 2;

my Bool:D $IPv6 = $*RESOLVER.lookup(family => PF_INET6).head.defined;

subtest 'IO::Socket::INET', {
    plan 32;

    splits-ok 'IPv4', PF_INET, '0.0.0.0', '127.0.0.1';
    splits-ok 'IPv6', PF_INET6, '::', '::1';
    splits-ok 'IPv4', PF_UNSPEC, '0.0.0.0', '127.0.0.1';
    splits-ok 'IPv6', PF_UNSPEC, '::', '::1';

    proto sub splits-ok(|) is test-assertion {*}
    multi sub splits-ok('IPv4', ProtocolFamily:D $family, Str:D $s-presentation, Str:D $c-presentation) {
        {
            my IO::Socket::INET:_ $server;
            my IO::Socket::INET:_ $client;

            lives-ok {
                $server .= listen: "$s-presentation:0", :$family;
            }, "can split IPv4 literals when listening with $family";
            fails-like {
                IO::Socket::INET.listen: "$s-presentation:65536", :$family;
            }, X::OutOfRange, "out-of-range ports fail when splitting IPv4 literals to listen with $family";

            lives-ok {
                $client .= connect: "$c-presentation:$server.local-address.port()", :$family;
            }, "can split IPv4 literals when connecting with $family";
            fails-like {
                IO::Socket::INET.connect: "$c-presentation:65536", :$family;
            }, X::OutOfRange, "out-of-range ports fails when splitting IPv4 literals to connect with $family";

            $server.close with $server;
            $client.close with $client;
        }

        {
            my IO::Socket::INET:_ $server;
            my IO::Socket::INET:_ $client;

            lives-ok {
                $server .= new: :localhost("$s-presentation:0"), :listen, :$family;
            }, "can split IPv4 literals when listening through .new with $family";
            fails-like {
                IO::Socket::INET.new: :localhost("$s-presentation:65536"), :listen, :$family;
            }, X::OutOfRange, "out-of-range ports fail when splitting IPv4 literals to listen through .new with $family";

            lives-ok {
                $client .= new: :host("$c-presentation:$server.local-address.port()"), :$family;
            }, "can split IPv4 literals when connecting through .new with $family";
            fails-like {
                IO::Socket::INET.new: :host("$c-presentation:65536"), :$family;
            }, X::OutOfRange, "out-of-range ports fail when splitting IPv4 literals to connect through .new with $family";

            $server.close with $server;
            $client.close with $client;
        }
    }
    multi sub splits-ok('IPv6', ProtocolFamily:D $family, Str:D $s-presentation, Str:D $c-presentation) {
        if $IPv6 {
            {
                my IO::Socket::INET:_ $server;
                my IO::Socket::INET:_ $client;

                lives-ok {
                    $server .= listen: "[$s-presentation]:0", :$family;
                }, "can split IPv6 literals when listening with $family";
                fails-like {
                    IO::Socket::INET.listen: "[$s-presentation]:65536", :$family;
                }, X::OutOfRange, "out-of-range ports fail when splitting IPv6 literals to listen with $family";

                lives-ok {
                    $client .= connect: "[$c-presentation]:$server.local-address.port()", :$family;
                }, "can split IPv6 literals when connecting with $family";
                fails-like {
                    IO::Socket::INET.connect: "[$c-presentation]:65536", :$family;
                }, X::OutOfRange, "out-of-range ports fails when splitting IPv6 literals to connect with $family";

                $server.close with $server;
                $client.close with $client;
            }

            {
                my IO::Socket::INET:_ $server;
                my IO::Socket::INET:_ $client;

                lives-ok {
                    $server .= new: :localhost("[$s-presentation]:0"), :listen, :$family;
                }, "can split IPv6 literals when listening through .new with $family";
                fails-like {
                    IO::Socket::INET.new: :localhost("[$s-presentation]:65536"), :listen, :$family;
                }, X::OutOfRange, "out-of-range ports fail when splitting IPv6 literals to listen through .new with $family";

                lives-ok {
                    $client .= new: :host("[$c-presentation]:$server.local-address.port()"), :$family;
                }, "can split IPv6 literals when connecting through .new with $family";
                fails-like {
                    IO::Socket::INET.new: :host("[$c-presentation]:65536"), :$family;
                }, X::OutOfRange, "out-of-range ports fail when splitting IPv6 literals to connect through .new with $family";

                $server.close with $server;
                $client.close with $client;
            }
        }
        else {
            skip 'IPv6 support required', 8;
        }
    }
};

subtest 'IO::Socket::Async', {
    plan 4;

    {
        my IO::Socket::Async::ListenSocket:_ $server;
        my IO::Socket::Async:_               $client;
        lives-ok {
            $server = IO::Socket::Async.listen('0.0.0.0:0').tap(*.close);
        }, 'can split IPv4 literals when listening';
        lives-ok {
            $client = await IO::Socket::Async.connect: "127.0.0.1:$server.local-address.port()"
        }, 'can split IPv4 literals when connecting';
        $client.close with $client;
        $server.close with $server;
    }

    if $IPv6 {
        my IO::Socket::Async::ListenSocket:_ $server;
        my IO::Socket::Async:_               $client;
        lives-ok {
            $server = IO::Socket::Async.listen('[::]:0').tap(*.close);
        }, 'can split IPv6 literals when listening';
        lives-ok {
            $client = await IO::Socket::Async.connect: "[::1]:$server.local-address.port()";
        }, 'can split IPv6 literals when connecting';
        $client.close with $client;
        $server.close with $server;
    }
    else {
        skip 'IPv6 support required', 2;
    }
};

# vim: expandtab shiftwidth=4
