package TestsFor::BitTrader::Config;
use Test::Most;
use base 'TestsFor';


sub startup : Test(startup)
{
	my $test = shift();
	$test->SUPER::startup;
	my $class = ref $test;
	$class->mk_classdata('default_Config');
	open(my $fh, ">conf.cfg");
	print $fh "var1 = testing \nvar2 = still testing";
	close($fh);
}

sub shutdown : Tests(shutdown) 
{
	my $test = shift();
	my $self = $test->default_Config();
	$test->SUPER::setup();
	unlink $self->_file();
}



sub setup : Test(setup)
{
	my $test = shift();
	$test->SUPER::setup();

	$test->default_Config( $test->class_to_test->new(_file => 'conf.cfg'));
} 


sub constructor : Test(3) 
{ 
	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, 'new';
	isa_ok $test->default_Config, $class;
	dies_ok {$class->new(_file => "missing.cfg")}, "Should die on missing file";
}

sub attributes : Test(2)
{
	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, "cfg";
	can_ok $class, "_file";
}

sub my_methods : Test(2)
{
	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, 'get_var';
	can_ok $class, 'set_var';
}

sub get_var : Test(2)
{
	my $test = shift();
	my $self = $test->default_Config();
	is $self->get_var("var1"), "testing", "var1 should be 'testing'";
	is $self->get_var("var2"), "still testing", "var1 should be 'still testing'";
}

sub set_var : Test(1)
{
	my $test = shift();
	my $self = $test->default_Config();

	$self->set_var("var1", "lame");

	is $self->get_var("var1"), "lame", "var1 should be 'lame'";
}


1;
