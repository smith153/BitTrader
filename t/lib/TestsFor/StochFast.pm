package TestsFor::BitTrader::Indicator::StochFast;
use Test::Most;
use base 'TestsFor';


sub startup : Test(startup)
{
	my $test = shift();
	$test->SUPER::startup;
	my $class = ref $test;
	$class->mk_classdata('default_StochFast');

}


sub setup : Test(setup)
{
	my $test = shift();
	$test->SUPER::setup();

	$test->default_StochFast( $test->class_to_test->new(
		k => 75,
		d => 70,
		stoch_size => 3,
		)
	);


} 


sub constructor : Test(2) 
{ 

	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, 'new';
	isa_ok $test->default_StochFast, $class;
}

sub attributes : Test(7)
{
	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, "price";
	can_ok $class, "_stoch_que";
	can_ok $class, "stoch_size";
	can_ok $class, "k";
	can_ok $class, "d";
	can_ok $class, "_k_avg";
	can_ok $class, "_d_avg";
}

sub my_methods : Test(5)
{
	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, '_update_indicator';
	can_ok $class, '_stochOsc';
	can_ok $class, 'should_buy';
	can_ok $class, 'should_sell';
	can_ok $class, 'status';
}

sub should_sell : Test(1)
{
	my $test = shift();
	my $self = $test->default_StochFast;
	is $self->should_sell, 0, "Market trending, we shouldn't sell";
}

sub should_buy : Test(1)
{
	my $test = shift();
	my $self = $test->default_StochFast;
	is $self->should_buy, 1, "Market trending, we should buy";
}

sub _stochOsc : Test(1)
{
	my $test = shift();
	my $self = $test->default_StochFast();
	$self->set_price(1);
	$self->set_price(2);
	$self->set_price(3);
	is $self->k, '100.00', "K should be 100";  
}

sub price : Test(5)
{
	my $test = shift();
	my $self = $test->default_StochFast();
	my $k = $self->k();
	my $d = $self->d();
	ok( (not $self->price()),"Price shouldn't be set");
	$self->set_price(10);
	ok(($self->k() == $k),"K should be the same until third iteration");
	$self->set_price(11);
	ok(($self->k() == $k),"K should be the same until third iteration");
	$self->set_price(12);
	ok(($self->k() != $k),"K should be different on the third iteration");
	is $self->price, 12, "Price is 12";

}

1;

