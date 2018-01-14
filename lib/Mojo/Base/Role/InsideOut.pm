package Mojo::Base::Role::InsideOut;

use Carp ();
use Mojo::Base -role;
use Mojo::Util qw{monkey_patch};
use Scalar::Util ();

my %OBJECT_REGISTRY;
my $CLASS = __PACKAGE__;

sub attr {
  my ($self, $attrs, $value) = @_;
  return unless (my $class = ref $self || $self) && $attrs;

  Carp::croak 'Default has to be a code reference or constant value'
    if ref $value && ref $value ne 'CODE';

  for my $attr (@{ref $attrs eq 'ARRAY' ? $attrs : [$attrs]}) {
    Carp::croak qq{Attribute "$attr" invalid} unless $attr =~ /^[a-zA-Z_]\w*$/;

    my $ref = $OBJECT_REGISTRY{ $CLASS } ||= {};
    if (ref $value) {
      monkey_patch $class, $attr, sub {
        my $id = Scalar::Util::refaddr $_[0];
        return
          exists $$ref{$id}{$attr} ? $$ref{$id}{$attr} : ($$ref{$id}{$attr} = $value->($_[0]))
          if @_ == 1;
        $$ref{$id}{$attr} = $_[1];
        $_[0];
      };
      }
    elsif (defined $value) {
      monkey_patch $class, $attr, sub {
        my $id = Scalar::Util::refaddr $_[0];
        return exists $$ref{$id}{$attr} ? $$ref{$id}{$attr} : ($$ref{$id}{$attr} = $value)
          if @_ == 1;
        $$ref{$id}{$attr} = $_[1];
        $_[0];
      };
    }
    else {
      monkey_patch $class, $attr,
        sub {
          my $id = Scalar::Util::refaddr $_[0];
          return $$ref{$id}{$attr} if @_ == 1; $$ref{$id}{$attr} = $_[1]; $_[0];
        };
    }
  }
}

after DESTROY => sub {
  my $id = Scalar::Util::refaddr +shift;
  # require Data::Dumper;
  # warn Data::Dumper::Dumper \%OBJECT_REGISTRY;
  delete $OBJECT_REGISTRY{$CLASS}{$id};
  # warn Data::Dumper::Dumper \%OBJECT_REGISTRY;
};

sub _count_objects {
  my %object_per_class;
  for my $class(keys %OBJECT_REGISTRY) {
    $object_per_class{$class} = scalar(keys %{$OBJECT_REGISTRY{$class}});
  }
  return \%object_per_class;
}

1;

=pod

=head1 NAME

Mojo::File::Role::InsideOut - The old inside out trick.

=head1 DESCRIPTION

  L<perlobj.pod#Inside-Out-objects>

=head1 METHODS

=head2 attr

=head2 DESTROY

=cut
