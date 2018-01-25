## no critic (MultiplePackages, RequireFilenameMatchesPackage)
use Mojo::Base -strict;

package Test::InsideOut;

use Mojo::Base -base;
use Role::Tiny::With;

with 'Mojo::Base::Role::InsideOut';

__PACKAGE__->attr(foo => sub { return 'bar' });

__PACKAGE__->attr(bar => 'foobar');

package Test::Again;
use Mojo::Base -base;
use Role::Tiny::With;

with 'Mojo::Base::Role::InsideOut';

__PACKAGE__->attr(rate => 1.5);
__PACKAGE__->attr(age => undef);

package main;

use Test::More;

my $io = new_ok('Test::InsideOut');

is $io->foo, 'bar', 'foo == bar';
is $io->foo('foo'), $io, 'chaining';
is $io->foo, 'foo', 'foo';

is $io->bar, 'foobar', 'bar == foobar';
is $io->bar('bar'), $io, 'chaining';
is $io->bar, 'bar', 'set';

is $io->clear('bar'), $io, 'can chain this';
is $io->bar, 'foobar', 'default again';

is $io->foo(1)->foo, 1, 'good';
is $io->bar(2)->bar, 2, 'good';
is $io->clear([qw{foo bar}]), $io, 'cleared mulitple - chainable';
is $io->foo, 'bar', 'default';
is $io->bar, 'foobar', 'default';
is $io->clear(['unwanted']), $io, 'no error';

eval {
  $io->attr('>>this one<<' => 7);
};
like $@, qr/Attribute.*invalid/, 'match';

eval {
  $io->attr('something' => \$io);
};
like $@, qr/Default has to be a code reference or constant value at/, 'match';

$io->attr([qw{alice bob charles}], undef);
can_ok $io, qw{alice bob charles};

is $io->attr, undef, 'nothing bad';

is eval "## chasing coverage
package One;
use Mojo::Base -strict;
use Mojo::Base::Role::InsideOut;
&Mojo::Base::Role::InsideOut::attr;
1;
", 1, 'nothing bad';


is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  1, 'one object';

my $again = new_ok('Test::Again');
is $again->rate, 1.5, 'rate default';
is $again->rate(2.0)->rate, 2.0, 'set rate';
is $again->age(), undef, 'not defined';
is $again->age(1)->age, 1, '1 unit of age';

is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  2, 'two objects';

undef $io;
is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  1, 'one object';

undef $again;
is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  0, 'no object';

my @iolist;
for (1 .. 100) {
  push @iolist, new_ok('Test::InsideOut')->foo('foo')->bar('bar');
  push @iolist, new_ok('Test::InsideOut');
  is $iolist[-1]->foo, 'bar', 'default';
}

is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  @iolist, 'more objects';

@iolist = ();
is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  @iolist, 'no objects';

for (1 .. 100) {
  push @iolist, new_ok('Test::InsideOut');
}

is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  0, 'none have property values objects';

is $_->foo, 'bar', 'default' for (@iolist);

is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  @iolist, 'no objects';

$io = new_ok('Test::InsideOut');

is $io->foo, 'bar', 'foo == bar';
is $io->foo('foo'), $io, 'chaining';
is $io->foo, 'foo', 'foo';

is $io->bar, 'foobar', 'bar == foobar';
is $io->bar('bar'), $io, 'chaining';
is $io->bar, 'bar', 'set';

@iolist = ();

is Mojo::Base::Role::InsideOut->_count_objects->{'Mojo::Base::Role::InsideOut'},
  1, 'one object';



done_testing;
