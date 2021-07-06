use v6;

use Test;

plan 27;

# L<S14/Parametric Subtyping>

role R1[::T] { }
role R1[::T1, ::T2] { }
class C1 { }
class C2 is C1 { }
class C3 { }

# Subtyping with a single role parameter which is a class type.
ok(R1[C1] ~~ R1,      'basic sanity');
ok(R1[C1] ~~ R1[C1],  'basic sanity');
ok(R1[C2] ~~ R1[C1],  'subtyping by role parameters (one param)');
ok(R1[C1] !~~ R1[C2], 'subtyping by role parameters (one param)');
ok(R1[C3] !~~ R1[C1], 'subtyping by role parameters (one param)');

# Subtyping with nested roles.
ok(R1[R1[C1]] ~~ R1,          'basic sanity');
ok(R1[R1[C1]] ~~ R1[R1[C1]],  'basic sanity');
ok(R1[R1[C2]] ~~ R1[R1[C1]],  'subtyping by role parameters (nested)');
ok(R1[R1[C1]] !~~ R1[R1[C2]], 'subtyping by role parameters (nested)');
ok(R1[R1[C3]] !~~ R1[R1[C1]], 'subtyping by role parameters (nested)');

# Subtyping with multiple role parameters.
ok(R1[C1,C3] ~~ R1,         'basic sanity');
ok(R1[C1,C3] ~~ R1[C1,C3],  'basic sanity');
ok(R1[C2,C3] ~~ R1[C1,C3],  'subtyping by role parameters (two params)');
ok(R1[C2,C2] ~~ R1[C1,C1],  'subtyping by role parameters (two params)');
ok(R1[C1,C1] !~~ R1[C2,C2], 'subtyping by role parameters (two params)');
ok(R1[C1,C2] !~~ R1[C2,C1], 'subtyping by role parameters (two params)');
ok(R1[C2,C1] !~~ R1[C1,C3], 'subtyping by role parameters (two params)');

# Use of parametric subtyping in dispatch.
sub s(C1 @arr) { 1 }   #OK not used
multi m(C1 @arr) { 2 }   #OK not used
multi m(@arr) { 3 }   #OK not used
my C2 @x;
is(s(@x), 1, 'single dispatch relying on parametric subtype');
is(m(@x), 2, 'multi dispatch relying on parametric subtype');

# Real types enforced.
sub modify(C1 @arr) {
    @arr[0] = C1.new;
}
dies-ok({ EVAL 'modify(@x)' }, 'type constraints enforced properly');

# Use of parametric subtyping for assignment.
my Numeric @a;
my Int @b = 1,2;
lives-ok({ @a = @b }, 'assignment worked as expected');
is(@a[0], 1,          'assignment worked as expected');

lives-ok({ EVAL(Q:to/ROLES/) }, 'can do subtyped generic roles');
role R2[Any ::T] { }
role R3[Cool ::T] does R2[T] { }
ROLES

EVAL(Q:to/TESTS/);
ok(R3[Cool] ~~ R2[Any],  'subtyped generic roles');
ok(R3[Cool] ~~ R3[Cool], 'subtyped generic roles');
ok(R3[Int] ~~ R3[Cool],  'subtyped generic roles');
TESTS

lives-ok({ EVAL(Q:to/ROLE/) }, 'can lookup roles of subtyped generic roles done by roles before they get composed');
multi sub trait_mod:<is>(Mu:U \T, :ok($)!) { T.^roles[0].^roles }
role R3[Int ::T] does R2[T] is ok { }
ROLE

# vim: expandtab shiftwidth=4
