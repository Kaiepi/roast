use v6;
use Test;

# NOTE:
# - Null hostnames are OK to resolve.
# - IP addresses are OK to resolve.
# - Domain names are *not* OK to resolve, as they require a DNS resolver to be
#   configured on the system.

plan 4;

subtest 'null hostnames', {
    plan 2;

    cmp-ok @($*RESOLVER.lookup.map: *.address),
           &[∋],
           all(IO::Address::IPv4('127.0.0.1'), IO::Address::IPv6('::1')),
           'resolutions for active sockets return loopback addresses';
    cmp-ok @($*RESOLVER.lookup(:passive).map: *.address),
           &[∋],
           all(IO::Address::IPv4('0.0.0.0'), IO::Address::IPv6('::')),
           'resolutions for passive sockets return unspecified addresses';
};

subtest 'IP addresses', {
    plan 3;

    cmp-ok @($*RESOLVER.lookup('127.0.0.1').map: *.address),
           &[∋],
           IO::Address::IPv4('127.0.0.1'),
           'can resolve IPv4 presentation-format addresses';
    cmp-ok @($*RESOLVER.lookup('::1').map: *.address),
           &[∋],
           IO::Address::IPv6('::1'),
           'can resolve IPv6 presentation-format addresses';
    cmp-ok @($*RESOLVER.lookup('::FFFF:127.0.0.1').map: *.address),
           &[∋],
           IO::Address::IPv6('::FFFF:127.0.0.1'),
           'can resolve mixed presentation-format addresses';
};

subtest 'binding', {
    plan 5;

    ok $*RESOLVER.bind(Str, {
        cmp-ok $^info.address,
               &[===],
               any(IO::Address::IPv4('127.0.0.1'), IO::Address::IPv6('::1')),
               'can bind addresses synchronously';
        True
    }), 'synchronous bindings return the return value of their callback';

    $*RESOLVER.bind: Str, -> IO::Address::Info:D $info, &left, &right {
        left X::AdHoc.new: payload => $info.address.presentation;
        True
    }, {
        is $^exception.message, <127.0.0.1 ::1>.any,
           'can throw errors when binding asynchronously';
    }, {
        flunk 'can throw errors when binding asynchronously';
    };

    $*RESOLVER.bind: Str, -> IO::Address::Info:D $info, &left, &right {
        right $info;
        True
    }, {
        flunk 'can emit results when binding asynchronously';
    }, {
        cmp-ok $^info.address,
               &[===],
               any(IO::Address::IPv4('127.0.0.1'), IO::Address::IPv6('::1')),
               'can emit results when binding asynchronously';
    };

    IO::Resolver::Native.new(BIND => -> | {
        pass 'can give native resolvers custom binding logic';
        True
    }).bind(Str, {
        flunk 'can give native resolvers custom binding logic';
    });
};

subtest 'connecting', {
    plan 5;

    ok $*RESOLVER.connect(Str, {
        cmp-ok $^info.address,
               &[===],
               IO::Address::IPv4('127.0.0.1'),
               'can bind addresses synchronously';
        True
    }), 'synchronous bindings return the return value of their callback';

    $*RESOLVER.connect: '127.0.0.1', -> IO::Address::Info:D $info, &left, &right {
        left X::AdHoc.new: payload => $info.address.presentation;
        True
    }, {
        is $^exception.message, <127.0.0.1 ::1>.any,
           'can throw errors when connecting asynchronously';
    }, {
        flunk 'can throw errors when connecting asynchronously';
    };

    $*RESOLVER.connect: '127.0.0.1', -> IO::Address::Info:D $info, &left, &right {
        right $info;
        True
    }, {
        flunk 'can emit results when connecting asynchronously';
    }, {
        cmp-ok $^info.address,
               &[===],
               any(IO::Address::IPv4('127.0.0.1'), IO::Address::IPv6('::1')),
               'can emit results when connecting asynchronously';
    };

    IO::Resolver::Native.new(CONNECT => -> | {
        pass 'can give native resolvers custom connection logic';
        True
    }).connect('127.0.0.1', {
        flunk 'can give native resolvers custom connection logic';
    });
};

# vim: ft=raku sw=4 ts=4 sts=4 et
