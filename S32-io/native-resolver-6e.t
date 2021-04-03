use v6.e.PREVIEW;
use Test;

# NOTE:
# - Null hostnames are OK to resolve.
# - IP addresses are OK to resolve.
# - Domain names are *not* OK to resolve, as they require a DNS resolver to be
#   configured on the system.

plan 1;

subtest 'connections', {
    plan 4;

    lives-ok {
        $*RESOLVER.connect: '127.0.0.1', {
            $++ ?? pass('can connect to addresses synchronously...') !! die($^info.address.presentation);
            True
        };
    }, '...during which any errors emitted are swallowed';

    my Bool:D $error = False;
    $*RESOLVER.connect: '127.0.0.1', -> IO::Address::Info:D $info, &left, &right {
        $++ ?? right($info.address) !! left(X::AdHoc.new: payload => $info.address.presentation);
        True
    }, { $error = True }, { pass 'can connect to an address asynchronously...' };
    nok $error, '...during which any errors emitted are swallowed';
};

# vim: ft=raku sw=4 ts=4 sts=4 et
