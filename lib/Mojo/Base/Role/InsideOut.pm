package Mojo::Base::Role::InsideOut;

use Carp ();
use Mojo::Base -role;
use Mojo::Util qw{monkey_patch};
use Scalar::Util ();

my %OBJECT_REGISTRY;
my $CLASS = __PACKAGE__;

our $VERSION = '0.03';

sub attr {
  my ($self, $attrs, $value) = @_;
  return unless (my $class = ref $self || $self) && $attrs;

  Carp::croak 'Default has to be a code reference or constant value'
    if ref $value && ref $value ne 'CODE';

  for my $attr (@{ref $attrs eq 'ARRAY' ? $attrs : [$attrs]}) {
    Carp::croak qq{Attribute "$attr" invalid}
      unless $attr =~ /^[a-zA-Z_]\w*$/xs;

    my $ref = $OBJECT_REGISTRY{$CLASS} ||= {};
    if (ref $value) {
      monkey_patch $class, $attr, sub {
        my $id = Scalar::Util::refaddr $_[0];
        return
          exists $ref->{$id}{$attr}
          ? $ref->{$id}{$attr}
          : ($ref->{$id}{$attr} = $value->($_[0]))
          if @_ == 1;
        $ref->{$id}{$attr} = $_[1];
        $_[0];
      };
    }
    elsif (defined $value) {
      monkey_patch $class, $attr, sub {
        my $id = Scalar::Util::refaddr $_[0];
        return
          exists $ref->{$id}{$attr}
          ? $ref->{$id}{$attr}
          : ($ref->{$id}{$attr} = $value)
          if @_ == 1;
        $ref->{$id}{$attr} = $_[1];
        $_[0];
      };
    }
    else {
      monkey_patch $class, $attr, sub {
        my $id = Scalar::Util::refaddr $_[0];
        return $ref->{$id}{$attr} if @_ == 1;
        $ref->{$id}{$attr} = $_[1];
        $_[0];
      };
    }
  }
  return;
}

sub clear {
  my ($self, $attrs) = @_;
  my $id = Scalar::Util::refaddr $self;
  for my $attr (@{ref $attrs eq 'ARRAY' ? $attrs : [$attrs]}) {
    delete $OBJECT_REGISTRY{$CLASS}{$id}{$attr};
  }
  return $self;
}

after DESTROY => sub {
  my $id = Scalar::Util::refaddr +shift;

  # require Data::Dumper;
  # warn Data::Dumper::Dumper \%OBJECT_REGISTRY;
  delete $OBJECT_REGISTRY{$CLASS}{$id};

  # warn Data::Dumper::Dumper \%OBJECT_REGISTRY;
};

sub DESTROY { }

sub _count_objects {    ## no critic (UnusedPrivateSubroutines)
  my %object_per_class;
  for my $class (keys %OBJECT_REGISTRY) {
    $object_per_class{$class} = scalar keys %{$OBJECT_REGISTRY{$class}};
  }
  return \%object_per_class;
}

1;

__END__

=pod

=head1 NAME

Mojo::Base::Role::InsideOut - The old inside out trick.

=begin html

<!-- Travis -->
<a href="https://travis-ci.org/kiwiroy/mojo-base-role-insideout">
  <img src="https://travis-ci.org/kiwiroy/mojo-base-role-insideout.svg?branch=master"
       alt="Build Status" />
</a>

<!-- Coveralls -->
<a href='https://coveralls.io/github/kiwiroy/mojo-base-role-insideout?branch=master'>
  <img src='https://coveralls.io/repos/github/kiwiroy/mojo-base-role-insideout/badge.svg?branch=master'
       alt='Coverage Status' />
</a>

<!-- Kritika -->
<a href="https://kritika.io/users/kiwiroy/repos/4971586310615065/heads/master/">
  <img src="https://kritika.io/users/kiwiroy/repos/4971586310615065/heads/master/status.svg"
       alt="Kritika Analysis Status"/>
</a>

=end html

=head1 DESCRIPTION

In order to add properties to L<non hash objects|perlobj#Non-Hash-Objects> such
as L<Mojo::File>, L<Mojo::Collection> and L<Mojo::ByteStream>, this
L<role|Role::Tiny> uses the once "experimental", though not universally adopted,
L<Inside Out Objects|perlobj#Inside-Out-objects>.

=head1 SYNOPSIS

  package File::Reader;
  use Mojo::Base 'Mojo::File';
  use Role::Tiny::With;
  with 'Mojo::Base::Role::InsideOut';

  __PACKAGE__->attr(fh => sub { $_[0]->open() });

=head1 PROPERTIES

No properties are available from this module, but may be defined by calling
classes using C<__PACKAGE__->attr>.

=head1 METHODS

The following methods are available, although as L<Role::Tiny> does not call
import on roles, they should be called thus:

  __PACKAGE__->method(@args);

=head2 attr

This is synonymous with L<attr|Mojo::Base#attr> from L<Mojo::Base>, but uses a
lexically scoped hash to record the properties in line with the
L<inside out|perlobj#Inside-Out-objects> model.

=head2 clear

Because it is difficult to run C<<delete $self->{attr_name}>> otherwise.

=cut
