use v6;

use Test;

plan 150;

# I'm using semi-random nouns for variable names since I'm tired of foo/bar/baz and alpha/beta/...

# L<S02/Names/>
# syn r14552

{
    my $mountain = 'Hill';
    $Terrain::mountain  = 108;
    $Terrain::Hill::mountain = 1024;
    our $river = 'Terrain::Hill';
    is($mountain, 'Hill', 'basic variable name');
    is($Terrain::mountain, 108, 'variable name with package');
    #?rakudo skip 'package variable autovivification RT #124637'
    is(Terrain::<$mountain>, 108, 'variable name with sigil not in front of package');
    is($Terrain::Hill::mountain, 1024, 'variable name with 2 deep package');
    #?rakudo skip 'package variable autovivification RT #124637'
    is(Terrain::Hill::<$mountain>, 1024, 'varaible name with sigil not in front of 2 package levels deep');
    is($Terrain::($mountain)::mountain, 1024, 'variable name with a package name partially given by a variable ');
    is($::($river)::mountain, 1024, 'variable name with package name completely given by variable');
}

{
    my $bear = 2.16;
    is($bear,       2.16, 'simple variable lookup');
    #?rakudo skip 'this kind of lookup NYI RT #125659'
    is($::{'bear'}, 2.16, 'variable lookup using $::{\'foo\'}');
    is(::{'$bear'}, 2.16, 'variable lookup using ::{\'$foo\'}');
    #?rakudo skip 'this kind of lookup NYI RT #125659'
    is($::<bear>,   2.16, 'variable lookup using $::<foo>');
    is(::<$bear>,   2.16, 'variable lookup using ::<$foo>');
}

#?rakudo skip '::{ } package lookup NYI RT #124638'
{
    my $::<!@#$> =  2.22;
    is($::{'!@#$'}, 2.22, 'variable lookup using $::{\'symbols\'}');
    is(::{'$!@#$'}, 2.22, 'variable lookup using ::{\'$symbols\'}');
    is($::<!@#$>,   2.22, 'variable lookup using $::<symbols>');
    is(::<$!@#$>,   2.22, 'variable lookup using ::<$symbols>');
}

# RT #65138, Foo::_foo() parsefails
{
    module A {
        our sub _b() { 'sub A::_b' }
    }
    is A::_b(), 'sub A::_b', 'A::_b() call works';
}

# RT #77750
is-deeply ::.^methods, PseudoStash.^methods, ':: is a valid PseudoStash';

# RT #63646
{
    throws-like 'OscarMikeGolf::whiskey_tango_foxtrot()',
      Exception,
      'dies when calling non-existent sub in non-existent package';
    throws-like 'Test::bravo_bravo_quebec()',
      Exception,
      'dies when calling non-existent sub in existing package';
    # RT #74520
    class TestA { };
    throws-like 'TestA::frobnosticate(3, :foo)',
      Exception,
      'calling non-existing function in foreign class dies';;
}

# RT #71194
{
    sub self { 4 };
    is self(), 4, 'can define and call a sub self()';
}

# RT #77528
# Subroutines whose names begin with a keyword followed by a hyphen
# or apostrophe
# RT #72438
# Subroutines with keywords for names (may need to be called with
# parentheses).
#?DOES 114
{
    for <
        foo package module class role grammar my our state let
        temp has augment anon supersede sub method submethod
        macro multi proto only regex token rule constant enum
        subset if unless while repeat for foreach loop given
        when default > -> $kw {
        eval-lives-ok "sub $kw \{}; {$kw}();",
            "sub named \"$kw\" called with parentheses";
        eval-lives-ok "sub {$kw}-rest \{}; {$kw}-rest;",
            "sub whose name starts with \"$kw-\"";
        eval-lives-ok "sub {$kw}'rest \{}; {$kw}'rest;",
            "sub whose name starts with \"$kw'\"";
    }
}

{
    my \s = 42;
    is s, 42, 'local terms override quoters';
    sub m { return 42 };
    is m, 42, 'local subs override quoters';
}

# RT #77006
isa-ok (rule => 1), Pair, 'rule => something creates a Pair';

# RT #69752
{
    throws-like { EVAL 'Module.new' },
      X::Undeclared::Symbols,
      'error message mentions name not recognized, no maximum recursion depth exceeded';
}

# RT #74276
# Rakudo had troubles with names starting with Q
lives-ok { EVAL 'class Quox { }; Quox.new' },
  'class names can start with Q';

# RT #58488
throws-like {
    EVAL 'class A { has $.a};  my $a = A.new();';
    EVAL 'class A { has $.a};  my $a = A.new();';
    EVAL 'class A { has $.a};  my $a = A.new();';
},
  X::Redeclaration,
  'can *not* redefine a class in EVAL -- classes are package scoped';

# RT #83874
{
    class Class { };
    ok Class.new ~~ Class, 'can call a class Class';
}

# RT #75646
{
    throws-like 'my ::foo $x, say $x', Exception,
        'no Null PMC access when printing a variable typed as ::foo ';
}

# RT #113892
{
    my module A {
        enum Day is export <Mon Tue>;
        sub Day is export { 'sub Day' }
    }
    import A;
    is Day(0), Mon, 'when enum and sub Day exported, Day(0) is enum coercer';
    is &Day(), 'sub Day', 'can get sub using & to disamgibuate';
}

# RT #115608
{
    my module foo {}
    sub foo() { "OH HAI" }
    ok foo.HOW ~~ Metamodel::ModuleHOW, 'when module and sub foo, bare foo is module type object';
    ok foo().HOW ~~ Metamodel::CoercionHOW, 'when module and sub foo, foo() is coercion type';
    is &foo(), 'OH HAI', 'can get sub using & to disambiguate';
}

{ # RT #128712
    constant $i = 42;
    my $foo:bar«$i» = 'meow';
    is-deeply $foo:bar«$i», 'meow', 'can use compile-time variables in names';
}

# vim: ft=perl6
