package TestsFor;
use Test::Most;
use base qw /Test::Class Class::Data::Inheritable/;


INIT { 
	__PACKAGE__->mk_classdata('class_to_test');
	Test::Class->runtests ;
}


#These run for EACH class
sub startup : Tests(startup) 
{
  my $test = shift();
  my $class = ref $test;
  $class =~ s/^TestsFor:://;
  eval "use $class";
  die $@ if $@;
  $test->class_to_test($class);
}
sub setup : Tests(setup) {}
sub teardown : Tests(teardown) {}
sub shutdown : Tests(shutdown) {}

1;
