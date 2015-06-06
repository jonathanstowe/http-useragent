use Test;

use HTTP::Header;

plan 14;

# new
my $h = HTTP::Header.new(a => "A", b => "B");

is ~$h.field('b'), 'B', 'new';

# field
is ~$h.field('a'), 'A', 'field 1/3';

$h.field(a => ['a', 'a1']);
is ~$h.field('a'), 'a, a1', 'field 2/3';

$h.field(a => 'a');
is ~$h.field('a'), 'a', 'field 3/3';

# init-field
$h.init-field(b => 'b');
is ~$h.field('b'), 'B', 'init-field 1/1';

# push-field
$h.push-field(a => ['a2', 'a3']);
is ~$h.field('a'), 'a, a2, a3', 'push-field 1/1';

# header-field-names
is $h.header-field-names.elems, 2, 'header-field-names 1/3';
is any($h.header-field-names), 'a', 'header-field-names 2/3';
is any($h.header-field-names), 'b', 'header-field-names 3/3';

# Str
is $h.Str, "a: a, a2, a3\nb: B\n", 'Str 1/2';
is $h.Str('|'), 'a: a, a2, a3|b: B|', 'Str 2/2';

# remove-field
$h.remove-field('a');
ok not $h.field('a'), 'remove-field 1/1';

# clear
$h.clear;
ok not $h.field('b'), 'clear 1/1';

subtest {
   my $h1 = HTTP::Header.new;
   my $h2 = HTTP::Header.new(a => 'b');

   lives-ok { $h1.merge($h2)} , "merge";
   is ~$h1.field('a'), 'b', "and got the new field in the first header";

   $h2 = HTTP::Header.new(a => 'c');
   lives-ok { $h1.merge($h2)} , "merge with same field name";
   is ~$h1.field('a'), 'b', "field in the first header is unchanged";

}, "merge";
