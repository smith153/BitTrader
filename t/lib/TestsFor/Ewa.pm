package TestsFor::Math::Ewa;
use Test::Most;
use base 'TestsFor';


sub startup : Test(startup)
{
	my $test = shift();
	$test->SUPER::startup;
	my $class = ref $test;
	$class->mk_classdata('default_Ewa');

}


sub setup : Test(setup)
{
	my $test = shift();
	$test->SUPER::setup();

	$test->default_Ewa( $test->class_to_test->new( alpha => 0.5));


} 


sub constructor : Test(3) 
{ 

	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, 'new';
	throws_ok {$class->new()} qr/Attribute.*required/, "Creating a $class without attributes should fail.";
	isa_ok $test->default_Ewa, $class;
}


sub attributes : Test(2)
{
	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, "alpha";
	can_ok $class, "last_avg";
}

sub my_methods : Test(2)
{
	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, 'ewa';
	can_ok $class, '_set_last_avg';
} 

sub ewa : Test(3)
{
	my $test = shift();
	my $self = $test->default_Ewa();

	my $value = 4;
	$value = $self->ewa($value);
	is $value, 4, "Avg is 4";
	$value = $self->ewa(8);
	is $value, 6, "Avg is 6";
	$value = $self->ewa(7);
	is $value, 6.5, "Avg is 6.5";  
}
