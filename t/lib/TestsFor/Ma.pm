package TestsFor::BitTrader::Indicator::Ma;
use Test::Most;
use Math::EWMA;
use base 'TestsFor';


sub startup : Test(startup)
{
	my $test = shift();
	$test->SUPER::startup;
	my $class = ref $test;
	$class->mk_classdata('default_Ma');

}


sub setup : Test(setup)
{
	my $test = shift();
	$test->SUPER::setup();

	$test->default_Ma( $test->class_to_test->new(
		avg => Math::EWMA->new(last_avg => 5, alpha => 1/8),
		avg_slow => Math::EWMA->new(last_avg => 4, alpha => 1/16),
		avg_slower => Math::EWMA->new(last_avg => 3, alpha => 1/32),
		avg_slowest => Math::EWMA->new(last_avg => 2, alpha => 1/128),
		)
	);


} 


sub constructor : Test(2) 
{ 

	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, 'new';
	isa_ok $test->default_Ma, $class;
}

sub attributes : Test(5)
{
	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, "price";
	can_ok $class, "avg";
	can_ok $class, "avg_slow";
	can_ok $class, "avg_slower";
	can_ok $class, "avg_slowest";
}

sub my_methods : Test(4)
{
	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, '_update_indicator';
	can_ok $class, 'should_buy';
	can_ok $class, 'should_sell';
	can_ok $class, 'status';
}

sub should_sell : Test(3)
{
	my $test = shift();
	my $self = $test->default_Ma;
	is $self->should_sell, 0, "Market trending, we shouldn't sell";

	for(my $i = 0; $i < 400; ++$i){
		$self->set_price($i);
	}


	for(my $i = 400; $i > 100; --$i){
		$self->set_price($i);
	}

	ok $self->should_sell, "Falling, we should sell";
	ok !$self->should_buy, "Falling, we shouldn't buy";
}

sub should_buy : Test(3)
{
	my $test = shift();
	my $self = $test->default_Ma;
	is $self->should_buy, 1, "Market trending, we should buy";

	for(my $i = 0; $i < 400; ++$i){
		$self->set_price($i);
	}

	ok $self->should_buy, "Trending, we should buy";
	ok !$self->should_sell, "Trending, we shouldn't sell";

}

sub price : Test(4)
{
	my $test = shift();
	my $self = $test->default_Ma();
	my $avg = $self->avg->last_avg();
	my $avg_slow = $self->avg_slow->last_avg();
	ok( (not $self->price()),"Price shouldn't be set");
	$self->set_price(10);
	is $self->price, 10, "Price is 10";
	ok $self->avg->last_avg() != $avg, "Average needs to change";
	ok $self->avg_slow->last_avg() != $avg_slow, "Average_slow needs to change";

}

1;

