use v6;
use Test;

plan 3;

subtest 'IO::Address::IPv4', {
    plan 11;

    subtest 'blobs (uint8)', {
        plan 5;

        my blob8:D             $blob     .= new: 0x7F, 0x00, 0x00, 0x01;
        my IO::Address::IPv4:_ $loopback;
        lives-ok {
            $loopback .= new: $blob
        }, 'can create an address from a network address';
        lives-ok {
            IO::Address::IPv4($blob)
        }, 'can coerce a network address to an address';
        dies-ok {
            IO::Address::IPv4.new: blob8.new
        }, 'cannot create an address from an invalid network address';
        cmp-ok IO::Address::IPv4(blob8.new), &[~~], Failure:D,
               'cannot coerce an invalid network address to an address';
        cmp-ok $loopback.network-address(blob8), &[eqv], $blob,
               'can get the network address of an address';
    };

    subtest 'blobs (uint16)', {
        plan 5;

        my blob16:D            $blob     .= new: 0x7F00, 0x0001;
        my IO::Address::IPv4:_ $loopback;
        lives-ok {
            $loopback .= new: $blob
        }, 'can create an address from a network address';
        lives-ok {
            IO::Address::IPv4($blob)
        }, 'can coerce a network address to an address';
        dies-ok {
            IO::Address::IPv4.new: blob16.new
        }, 'cannot create an address from an invalid network address';
        cmp-ok IO::Address::IPv4(blob16.new), &[~~], Failure:D,
               'cannot coerce an invalid network address to an address';
        cmp-ok $loopback.network-address(blob16), &[eqv], $blob,
               'can get the network address of an address';
    };

    subtest 'blobs (uint32)', {
        plan 5;

        my blob32:D            $blob     .= new: 0x7F000001;
        my IO::Address::IPv4:_ $loopback;
        lives-ok {
            $loopback .= new: $blob
        }, 'can create an address from a network address';
        lives-ok {
            IO::Address::IPv4($blob)
        }, 'can coerce a network address to an address';
        dies-ok {
            IO::Address::IPv4.new: blob32.new
        }, 'cannot create an address from an invalid network address';
        cmp-ok IO::Address::IPv4(blob32.new), &[~~], Failure:D,
               'cannot coerce an invalid network address to an address';
        cmp-ok $loopback.network-address(blob32), &[eqv], $blob,
               'can get the network address of an address';
    };

    subtest 'integers', {
        plan 5;

        my Int:D               $integer   = 0x7F000001;
        my IO::Address::IPv4:_ $loopback;
        lives-ok {
            $loopback .= new: $integer
        }, 'can create an address from a network address';
        lives-ok {
            IO::Address::IPv4($integer)
        }, 'can coerce a network address to an address';
        dies-ok {
            IO::Address::IPv4.new: 1 +< 32
        }, 'cannot create an address from an out-of-range network address';
        cmp-ok IO::Address::IPv4(1 +< 32), &[~~], Failure:D,
               'cannot coerce an out-of-range network address to an address';
        cmp-ok $loopback.network-address, &[==], $integer,
               'can get the network address of an address';
    };

    subtest 'presentation formatting', {
        plan 5;

        my Str:D               $presentation = '127.0.0.1';
        my IO::Address::IPv4:_ $loopback;
        lives-ok {
            $loopback .= new: $presentation
        }, 'can create an address from a presentation-format addresses';
        lives-ok {
            IO::Address::IPv4($presentation)
        }, 'can coerce a presentation-format address to an address';
        dies-ok {
            IO::Address::IPv4.new: '1 Main St.'
        }, 'cannot create an address from a nonsense';
        dies-ok {
            $loopback .= new: "0$presentation";
        }, 'a presentation-format address is parsed with inet_pton semantics, not those of inet_aton';
        is $loopback.presentation, '127.0.0.1',
           'can get the presentation format of an address';
    };

    subtest 'ports', {
        plan 3;

        my Int:D               $port      = 80;
        my IO::Address::IPv4:_ $loopback;
        lives-ok {
            $loopback .= new: '127.0.0.1', :$port;
        }, 'can create an address with a port';
        dies-ok {
            $loopback .= new: '127.0.0.1', :port(0x10000)
        }, 'cannot create an address with an out-of-range port';
        cmp-ok $loopback.port, &[==], $port,
               'can get the port of an address';
    };

    subtest 'literals', {
        plan 3;

        my Str:D               $literal  = '127.0.0.1:80';
        my IO::Address::IPv4:_ $loopback;
        lives-ok {
            $loopback = IO::Address::IPv4($literal);
        }, 'can coerce a literal to an address';
        cmp-ok IO::Address::IPv4('1 Main St.'), &[~~], Failure:D,
               'cannot coerce an invalid literal to an address';
        is $loopback.literal, $literal,
           'can get the literal of an address';
    };

    subtest 'coercions', {
        plan 2;

        my IO::Address::IPv4:D $loopback = IO::Address::IPv4('127.0.0.1');
        cmp-ok $loopback, &[eq], $loopback.literal,
               'can coerce addresses to Str:D';
        cmp-ok $loopback, &[==], 0x7F000001,
               'can coerce addresses to Int:D';
    };

    subtest 'equality', {
        plan 4;

        my IO::Address::IPv4:D $loopback = IO::Address::IPv4('127.0.0.1:80');
        cmp-ok $loopback, &[===], $loopback,
               '=== OK';
        cmp-ok $loopback, &[!===], IO::Address::IPv4('0.0.0.0:80'),
               '!=== OK';
        cmp-ok $loopback, &[eqv], IO::Address::IPv4('127.0.0.1'),
               'eqv OK';
        cmp-ok $loopback, &[!eqv], IO::Address::IPv4('0.0.0.0'),
               '!eqv OK';
    };

    subtest 'convenience methods', {
        plan 14;

        ok IO::Address::IPv4('0.0.0.0').is-unspecified,
           'a unspecified address is a unspecified address';
        nok IO::Address::IPv4('127.0.0.1').is-unspecified,
            'a non-unspecified address is not a  unspecified address';

        ok IO::Address::IPv4('127.0.0.1').is-loopback,
           'a loopback address is a loopback address';
        nok IO::Address::IPv4('0.0.0.0').is-loopback,
            'a non-loopback address is not a  loopback address';

        ok IO::Address::IPv4('255.255.255.255').is-broadcast,
           'a broadcast address is a broadcast address';
        nok IO::Address::IPv4('0.0.0.0').is-broadcast,
           'a non-broadcast address is not a  broadcast address';

        ok IO::Address::IPv4('10.0.0.1').is-private,
           'a /24 private address is a private address';
        ok IO::Address::IPv4('172.16.0.1').is-private,
           'a /20 private address is a private address';
        ok IO::Address::IPv4('192.168.0.1').is-private,
           'a /16 private address is a private address';
        nok IO::Address::IPv4('0.0.0.0').is-private,
            'a non-private address is not a  private address';

        ok IO::Address::IPv4('100.64.0.1').is-shared,
           'a shared address is a shared address';
        nok IO::Address::IPv4('0.0.0.0').is-shared,
            'a non-shared address is not a  shared address';

        ok IO::Address::IPv4('169.254.0.1').is-link-local,
           'a link-local address is a link-local address';
        nok IO::Address::IPv4('0.0.0.0').is-link-local,
            'a non-link-local address is not a  link-local address';
    };

    subtest 'stringification', {
        plan 2;

        my IO::Address::IPv4:D $loopback = IO::Address::IPv4('127.0.0.1');
        is $loopback.gist, $loopback.literal,
           'can get the gist of an address';
        is $loopback.raku, 'IO::Address::IPv4("127.0.0.1:0")',
           'can get the raku of an address';
    };
};

subtest 'IO::Address::IPv6', {
    plan 13;

    subtest 'blobs (uint8)', {
        plan 5;

        my blob8:D             $blob     .= new: |(0 xx 15), 1;
        my IO::Address::IPv6:_ $loopback;
        lives-ok {
            $loopback .= new: $blob
        }, 'can create an address from a network address';
        lives-ok {
            IO::Address::IPv6($blob)
        }, 'can coerce a network address to an address';
        dies-ok {
            IO::Address::IPv6.new: blob8.new
        }, 'cannot create an address from an invalid network address';
        dies-ok {
            IO::Address::IPv6(blob8.new)
        }, 'cannot coerce an invalid network address to an address';
        cmp-ok $loopback.network-address(blob8), &[eqv], $blob,
               'can get the network address of an address';
    };

    subtest 'blobs (uint16)', {
        plan 5;

        my blob16:D            $blob     .= new: |(0 xx 7), 1;
        my IO::Address::IPv6:_ $loopback;
        lives-ok {
            $loopback .= new: $blob
        }, 'can create an address from a network address';
        lives-ok {
            IO::Address::IPv6($blob)
        }, 'can coerce a network address to an address';
        dies-ok {
            IO::Address::IPv6.new: blob16.new
        }, 'cannot create an address from an invalid network address';
        cmp-ok IO::Address::IPv6(blob16.new), &[~~], Failure:D,
               'cannot coerce an invalid network address to an address';
        cmp-ok $loopback.network-address(blob16), &[eqv], $blob,
               'can get the network address of an address';
    };

    subtest 'blobs (uint32)', {
        plan 5;

        my blob32:D            $blob     .= new: |(0 xx 3), 1;
        my IO::Address::IPv6:_ $loopback;
        lives-ok {
            $loopback .= new: $blob
        }, 'can create an address from a network address';
        lives-ok {
            IO::Address::IPv6($blob)
        }, 'can coerce a network address to an address';
        dies-ok {
            IO::Address::IPv6.new: blob32.new
        }, 'cannot create an address from an invalid network address';
        cmp-ok IO::Address::IPv6(blob32.new), &[~~], Failure:D,
               'cannot coerce an invalid network address to an address';
        cmp-ok $loopback.network-address(blob32), &[eqv], $blob,
               'can get the network address of an address';
    };

    subtest 'blobs (uint64)', {
        plan 5;

        my blob64:D            $blob     .= new: 0, 1;
        my IO::Address::IPv6:_ $loopback;
        lives-ok {
            $loopback .= new: $blob
        }, 'can create an address from a network address';
        lives-ok {
            IO::Address::IPv6($blob)
        }, 'can coerce a network address to an address';
        dies-ok {
            IO::Address::IPv6.new: blob64.new
        }, 'cannot create an address from an invalid network address';
        cmp-ok IO::Address::IPv6(blob64.new), &[~~], Failure:D,
               'cannot coerce an invalid network address to an address';
        cmp-ok $loopback.network-address(blob64), &[eqv], $blob,
               'can get the network address of an address';
    };

    subtest 'integers', {
        plan 5;

        my Int:D               $integer   = 1;
        my IO::Address::IPv6:_ $loopback;
        lives-ok {
            $loopback .= new: $integer
        }, 'can create an address from a network address';
        lives-ok {
            IO::Address::IPv6($integer)
        }, 'can coerce a network address to an address';
        dies-ok {
            IO::Address::IPv6.new: 1 +< 128
        }, 'cannot create an address from an out-of-range network address';
        cmp-ok IO::Address::IPv6(1 +< 128), &[~~], Failure:D,
               'cannot coerce an out-of-range network address to an address';
        cmp-ok $loopback.network-address, &[==], $integer,
               'can get the network address of an address';
    };

    subtest 'presentation formatting', {
        plan 6;

        my Str:D               $loopback-presentation = '::1';
        my Str:D               $mixed-presentation    = '::ffff:0.0.0.0';
        my IO::Address::IPv6:_ $loopback;
        my IO::Address::IPv6:_ $mixed;
        lives-ok {
            $loopback .= new: $loopback-presentation
        }, 'can create an address from a presentation-format address';
        lives-ok {
            IO::Address::IPv6($loopback-presentation)
        }, 'can coerce a presentation-format address to an address';
        dies-ok {
            IO::Address::IPv6.new: '1 Main St.'
        }, 'cannot create an address from nonsense';
        lives-ok {
            $mixed .= new: $mixed-presentation;
        }, 'can create an address from a mixed presentation-format address';
        is $loopback.presentation, $loopback-presentation,
           'can get the (compressed!) presentation format of an address';
        is $mixed.presentation, $mixed-presentation,
           'can get the (mixed!) presentation format of an address';
    };

    subtest 'ports', {
        plan 3;

        my Int:D               $port     = 80;
        my IO::Address::IPv6:_ $loopback;
        lives-ok {
            $loopback .= new: '::1', :$port
        }, 'can create an address with a port';
        dies-ok {
            IO::Address::IPv6.new: '::1', :port(0x10000)
        }, 'cannot create an address with an out-of-range port';
        cmp-ok $loopback.port, &[==], $port,
               'can get the port of an address';
    };

    subtest 'zones', {
        plan 5;

        my Int:D               $scope-id   = 1;
        my Str:D               $zone-id    = "$scope-id";
        my IO::Address::IPv6:_ $link-local;
        lives-ok {
            $link-local .= new: 'fe80::1', :$zone-id
        }, 'can create an address with a zone ID';
        lives-ok {
            IO::Address::IPv6.new: 'fe80::1', :zone-id($scope-id)
        }, 'can create an address with a scope ID';
        dies-ok {
            IO::Address::IPv6.new: 'fe80::1', :zone-id(-1)
        }, 'cannot create an address with an out-of-range scope ID';
        is $link-local.zone-id, $zone-id,
           'zone IDs are idempotent';
        cmp-ok $link-local.scope-id, &[==], $scope-id,
               'can get the scope ID of an address';
    };

    subtest 'literals', {
        plan 4;

        my Str:D               $loopback-literal  = '[::1]:80';
        my IO::Address::IPv6:_ $loopback;
        lives-ok {
            $loopback = IO::Address::IPv6($loopback-literal)
        }, 'can coerce a literal to an address';
        cmp-ok IO::Address::IPv6('1 Main St.'), &[~~], Failure:D,
               'cannot coerce nonsense to an address';
        is $loopback.literal, $loopback-literal,
           'can get the literal of an address without a zone ID';
        is IO::Address::IPv6('[fe80::1%1]:80').literal, '[fe80::1%1]:80',
           'can get the literal of an address with a zone ID';
    };

    subtest 'coercions', {
        plan 2;

        my IO::Address::IPv6:D $loopback = IO::Address::IPv6('::1');
        cmp-ok $loopback, &[eq], $loopback.literal,
               'can coerce an address to a Str:D';
        cmp-ok $loopback, &[==], $loopback.network-address,
               'can coerce an address to an Int:D';
    };

    subtest 'equality', {
        plan 4;

        my IO::Address::IPv6:D $loopback = IO::Address::IPv6('[::1]:80');
        cmp-ok $loopback, &[===], $loopback,
               '=== OK';
        cmp-ok $loopback, &[!===], IO::Address::IPv6('::1'),
               '!=== OK';
        cmp-ok $loopback, &[eqv], IO::Address::IPv6('::1'),
               'eqv OK';
        cmp-ok $loopback, &[!eqv], IO::Address::IPv6('::'),
               '!eqv OK';
    };

    subtest 'convenience methods', {
        plan 25;

        ok IO::Address::IPv6('::').is-unspecified,
           'an unspecified address is an unspecified address';
        nok IO::Address::IPv6('::1').is-unspecified,
            'a non-unspecified address is not an unspecified address';

        ok IO::Address::IPv6('::1').is-loopback,
           'a loopback address is a loopback address';
        nok IO::Address::IPv6('::').is-loopback,
            'a non-loopback address is not a loopback address';

        ok IO::Address::IPv6('::127.0.0.1').is-ipv4-compatible,
           'an IPv4-compatible IPv6 address is an IPv4-compatible IPv6 address';
        nok IO::Address::IPv6('::ffff:127.0.0.1').is-ipv4-compatible,
            'a non-IPv4-compatible IPv6 address is not an IPv4-compatible IPv6 address';

        ok IO::Address::IPv6('::ffff:127.0.0.1').is-ipv4-mapped,
           'an IPv4-mapped IPv6 address is an IPv4-mapped IPv6 address';
        nok IO::Address::IPv6('::127.0.0.1').is-ipv4-mapped,
            'a non-IPv4-mapped IPv6 address is not an IPv4-mapped IPv6 address';

        ok IO::Address::IPv6('2002::1').is-ipv4-encapsulatable,
           'a 6to4 address is a 6to4 address';
        nok IO::Address::IPv6('::1').is-ipv4-encapsulatable,
            'a non-6to4 address is not a 6to4 address';

        ok IO::Address::IPv6('ff00::1').is-multicast,
           'a multicast address is a multicast address';
        nok IO::Address::IPv6('fe80::1').is-multicast,
            'a non-multicast address is not a multicast address';

        ok IO::Address::IPv6('fe80::1').is-unicast,
           'a unicast address is a unicast address';
        nok IO::Address::IPv6('ff00::1').is-unicast,
            'a non-unicast address is not a unicast address';

        cmp-ok IO::Address::IPv6('ff01::1').scope, &[==], 0x1,
               'can get the scope of a multicast address';
        cmp-ok IO::Address::IPv6('fe80::1').scope, &[==], 0x2,
               'can get the scope of a link-local unicast address';
        cmp-ok IO::Address::IPv6('fec0::1').scope, &[==], 0x5,
               'can get the scope of a site-local unicast address';
        cmp-ok IO::Address::IPv6('::1').scope, &[==], 0xE,
               'can get the scope of a global unicast address';

        ok IO::Address::IPv6('ff01::1').is-interface-local,
           'an interface-local address is an interface-local address';
        ok IO::Address::IPv6('ff02::1').is-link-local,
           'a link-local address is a link-local address';
        ok IO::Address::IPv6('ff03::1').is-realm-local,
           'a realm-local address is a realm-local address';
        ok IO::Address::IPv6('ff04::1').is-admin-local,
           'an admin-local address is an admin-local address';
        ok IO::Address::IPv6('ff05::1').is-site-local,
           'a site-local address is a site-local address';
        ok IO::Address::IPv6('ff08::1').is-organization-local,
           'an organization-local address is an organization-local address';
        ok IO::Address::IPv6('ff0e::1').is-global,
           'a global address is a global address';
    };

    subtest 'stringification', {
        plan 2;

        my IO::Address::IPv6:D $loopback = IO::Address::IPv6('::1');
        is $loopback.gist, $loopback.literal,
           'can get the gist of an address';
        is $loopback.raku, 'IO::Address::IPv6("[::1]:0")',
           'can get the raku of an address';
    };
};

if $*DISTRO.is-win {
    skip 'Windows UNIX socket support NYI', 1;
}
else {
#?rakudo.jvm 1 skip JVM UNIX socket support NYI
    subtest 'IO::Address::UNIX', {
        plan 6;

        subtest 'paths', {
            plan 5;

            my IO::Path:D          $path = './foo'.IO;
            my IO::Address::UNIX:_ $foo;
            lives-ok {
                $foo .= new: $path
            }, 'can create an address from a path';
            lives-ok {
                $foo .= new: "$path"
            }, 'can create an address from a string';
            lives-ok {
                $foo = IO::Address::UNIX($path)
            }, 'can coerce a path to an address';
            lives-ok {
                $foo = IO::Address::UNIX("$path")
            }, 'can coerce a string to an address';
            is $foo.path, $path,
               'can get the path of an address';
        };

        subtest 'blobs (int8)', {
            plan 3;

            my Blob[int8]          $blob .= new: 0;
            my IO::Address::UNIX:_ $foo;
            lives-ok {
                $foo .= new: $blob
            }, 'can create an address from a blob';
            lives-ok {
                $foo = IO::Address::UNIX($blob)
            }, 'can coerce a blob to an address';
            cmp-ok $foo.raw, &[eqv], $blob,
                   'can get a blob representation of an address';
        };

        subtest 'blobs (uint8)', {
            plan 3;

            my blob8:D             $blob .= new: 0;
            my IO::Address::UNIX:_ $foo;
            lives-ok {
                $foo .= new: $blob
            }, 'can create an address from a blob';
            lives-ok {
                $foo = IO::Address::UNIX($blob)
            }, 'can coerce a blob to an address';
            cmp-ok $foo.raw(blob8), &[eqv], $blob,
                   'can get a blob representation of an address';
        };

        subtest 'coercions', {
            plan 2;

            my IO::Path:D          $path  = './foo'.IO;
            my IO::Address::UNIX:D $foo  .= new: $path;
            is $foo.IO, $path,
               'can coerce addresses to paths';
            is $foo, $path,
               'can coerce addresses to strings';
        };

        subtest 'equality', {
            plan 4;

            my IO::Address::UNIX:D $foo .= new: './foo';
            my IO::Address::UNIX:D $bar .= new: './bar';
            cmp-ok $foo, &[eqv], $foo,
                   'eqv OK';
            cmp-ok $foo, &[!eqv], $bar,
                   '!eqv OK';
            cmp-ok $foo, &[===], $foo,
                   '=== OK';
            cmp-ok $foo, &[!===], $bar,
                   '!=== OK';
        };

        subtest 'stringification', {
            plan 2;

            my Blob[int8]          $blob .= new: |'./foo'.encode;
            my IO::Address::UNIX:D $foo  .= new: './foo';
            is $foo.gist, "$foo",
               'can get the gist of an address';
            is $foo.raku, 'IO::Address::UNIX.new(' ~ $blob.raku ~ ')',
               'can get the raku of an address';
        };
    };
}

# vim: ft=raku sw=4 ts=4 sts=4 et
