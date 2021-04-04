use v6;
use Test;

plan 7;

my $s-address = '0.0.0.0';
my $c-address = '127.0.0.1';
my $port    = 5001;

{
    my $sock = IO::Socket::Async.bind-udp($s-address, $port);
    dies-ok { IO::Socket::Async.bind-udp($s-address, $port) },
        'Error on trying to re-use port with UDP bind';
    $sock.close;
}

# Promise used to check listener received the correct data.
my $rec-prom;

# Listener
my $sock = IO::Socket::Async.bind-udp($s-address, $port);
is $sock.local-domain, $s-address,
   'can get the local domain of a server';
my $tap = $sock.Supply.tap: -> $chars {
    if $chars.chars > 0 {
        $rec-prom.keep($chars);
    }
}
LEAVE $sock.close;

# Client print-to
{
    $rec-prom = Promise.new;
    my $sock = IO::Socket::Async.udp();
    $sock.print-to($c-address, $port, "Unusually Dubious Protocol");
    is $rec-prom.result, "Unusually Dubious Protocol", "Sent/received data with UDP (print)";
    $sock.close;
}

# Client write-to
{
    $rec-prom = Promise.new;
    my $sock = IO::Socket::Async.udp();
    $sock.write-to($c-address, $port, "Unhelpful Dataloss Protocol".encode('ascii'));
    is $rec-prom.result, "Unhelpful Dataloss Protocol", "Sent/received data with UDP (write)";
    $sock.close;
}

{
    temp $s-address = IO::Address::IPv4("$s-address:$port");

    my IO::Socket::Async:_ $client .= udp;
    is $sock.local-domain, $s-address.presentation,
       'can get the local domain of a server';
    cmp-ok $sock.local-address, &[===], $s-address,
           'can get the local address of a server';
    lives-ok {
        $client.print-to: $s-address, "ok$?NL"
    }, 'can write to addresses';
    $client.close;
}

# vim: expandtab shiftwidth=4
