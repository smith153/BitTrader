package TestsFor::Math::Sma;
use Test::Most;
use base 'TestsFor';


sub startup : Test(startup)
{
	my $test = shift();
	$test->SUPER::startup;
	my $class = ref $test;
	$class->mk_classdata('default_Sma');
}


sub setup : Test(setup)
{
	my $test = shift();
	$test->SUPER::setup();

	$test->default_Sma( $test->class_to_test->new( size => 3));
} 


sub constructor : Test(3) 
{ 

	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, 'new';
	throws_ok {$class->new()} qr/Attribute.*required/, "Creating a $class without attributes should fail.";
	throws_ok {$class->new(size => 1.5)} qr/Attribute.*constraint/, "Creating a $class with float should fail";
	isa_ok $test->default_Sma, $class;
}


sub attributes : Test(3)
{
	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, "size";
	can_ok $class, "last_avg";
	can_ok $class, "_values";
}

sub my_methods : Test(5)
{
	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, 'sma';
	can_ok $class, '_raw_average';
	can_ok $class, '_set_last_avg';
	can_ok $class, '_push_value';
	can_ok $class, '_shift_value';
} 

sub sma : Test(3)
{
	my $test = shift();
	my $self = $test->default_Sma();

	my $value = 4;
	$value = $self->sma($value);
	is $value, "4.00", "Avg is 4.00";
	$value = $self->sma(8);
	is $value, "6.00", "Avg is 6.00";
	$value = $self->sma(7);
	is $value, "6.33", "Avg is 6.33";
	$value = $self->sma(9);
	is $value, "8.00", "Avg is 8.00";  
}

1;

