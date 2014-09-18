package TestsFor;
use Test::Most;
use base qw /Test::Class Class::Data::Inheritable/;


INIT { 
	__PACKAGE__->mk_classdata('class_to_test');
	Test::Class->runtests ;
}


#These run for EACH class
#runs before each class load
sub startup : Tests(startup)
{
  my $test = shift();
  my $class = ref $test;
  $class =~ s/^TestsFor:://;
  eval "use $class";
  die $@ if $@;
  $test->class_to_test($class);
}
#runs before each method call
sub setup : Tests(setup) {}
#runs after each method call
sub teardown : Tests(teardown) {}
#runs after each class ends
sub shutdown : Tests(shutdown) {}

1;
