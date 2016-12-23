#!/usr/bin/env perl6
# Generates tests from GraphemeBreakPropertyTest.txt from UNIDATA
use v6;
sub MAIN ( Str $GrahemeBreakTest-file ) {
    my @text = $GrahemeBreakTest-file.IO.slurp.lines;
    my $line-no = 0;
    my @array;
    for @text -> $line {
        $line-no++;
        next if $line ~~ / ^ \s* '#' /;
        $line ~~ / ^ $<beginning>=(.*) '#' $<comment>=( .* ) $ /;
        my $comment = $<comment>.trim;
        my $beginning = $<beginning>.trim;
        # Remove the beginning and end, since we always break at start and end of string
        $beginning ~~ s/ ^ .*? ( <:AHex> .* <:AHex> ) .*? $ /$0/;
        # Remove all the 'break' symbols, we only care about where *not* to break
        $beginning ~~ s:g/'÷'//;
        my $no-break = 0;
        # CCount how many codepoints we are not supposed to break between
        while $beginning ~~ s/'×'// {
            $no-break++;
        }
        $beginning ~~ s:g/' '+/ /;
        my $string;
        my $uni-codes;
        my $fail= False;
        for $beginning.split(' ') -> $thing is copy {
            next if $thing eq '';
            my $number = $thing.parse-base(16);
            # Private Use High Surrogate is probably not supposed to be used in UTF-8
            if $number eq '55296' {
                $fail = True;
                last;
            }
            $string ~= $thing.parse-base(16).chr;
            $uni-codes ~= "0x$thing.parse-base(16).base(16), ";
            CATCH {$fail = True; last; }
        }
        next if $fail == True;
        $uni-codes ~~ s/ ', ' $ //;
        my $should-be;
        $should-be = $string.codes - $no-break;
        push @array, qq<is Uni.new($uni-codes).Str.chars, $should-be, "GraphemeBreakTest Line: $line-no Codes: $string.codes() Non-break: $no-break";>;
    }
    my $file =
    qq:to/END/;
    use v6;
    use Test;
    plan @array.elems();

    END
    for @array {
        $file ~= $_ ~ "\n";
    }
    spurt "S15-nfg/GraphemeBreakPropertyTest.t", $file;
}
