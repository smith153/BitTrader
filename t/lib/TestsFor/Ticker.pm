package TestsFor::BitTrader::Ticker;
use Test::Most;
use base 'TestsFor';


sub startup : Test(startup)
{
	my $test = shift();
	$test->SUPER::startup;
	my $class = ref $test;
	$class->mk_classdata('default_Ticker');

}


sub setup : Test(setup)
{
	my $test = shift();
	$test->SUPER::setup();

	$test->default_Ticker( $test->class_to_test->new(
		symbol => 'ltc',
		_file => '/tmp/.indicator_test',
		)
	);


} 

sub teardown : Tests(teardown) 
{
	my $test = shift();
	my $self = $test->default_Ticker();
	$test->SUPER::setup();
	unlink $self->_file();
}

sub constructor : Test(3) 
{ 

	my $test = shift();
	my $class = $test->class_to_test();
	throws_ok {$class->new()} qr/Attribute.*required/, "Creating a $class without attributes should fail.";
	can_ok $class, 'new';
	isa_ok $test->default_Ticker, $class;
}

sub attributes : Test(7)
{
	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, "symbol";
	can_ok $class, "amount";
	can_ok $class, "price";
	can_ok $class, "last_action";
	can_ok $class, "indicators";
	can_ok $class, "cur_indicator";
	can_ok $class, "_cfg";
}

sub my_methods : Test(9)
{
	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, 'ticker_status';
	can_ok $class, 'get_indicator';
	can_ok $class, '_update_indicators';
	can_ok $class, 'should_buy';
	can_ok $class, 'should_sell';
	can_ok $class, '_add_indicator';
	can_ok $class, '_get_indicator';
	can_ok $class, '_list_indicators';
	can_ok $class, '_indicator_valid';
	can_ok $class, '_set_cfg';
}

sub get_indicator : Test(3)
{
	my $test = shift();
	my $self = $test->default_Ticker;
	my $file = $self->_file();

	system("echo 'StochOsc' > $file");
	$self->get_indicator();
	is ref($self->indicator()), "BitTrader::Indicator::StochOsc", "Indicator should be StochOsc";

	system("echo 'Ma' > $file");
	$self->get_indicator();
	is ref($self->indicator()), "BitTrader::Indicator::Ma", "Indicator should be Ma";

	system("echo 'StochFast' > $file");
	$self->get_indicator();
	is ref($self->indicator()), "BitTrader::Indicator::StochFast", "Indicator should be StochFast";

}

sub _update_indicators : Test(4)
{
	my $test = shift();
	my $self = $test->default_Ticker;

	$self->_update_indicators(111);
	is $self->indicator()->price(), 111, "Indicator should be 111";
	is $self->StochOsc()->price(), 111, "StochOsc price should be 111";
	is $self->StochFast()->price(), 111, "StochFast price should be 111";
	is $self->Ma()->price(), 111, "Ma price should be 111";
}



sub should_sell : Test(3)
{
	my $test = shift();
	my $self = $test->default_Ticker;
	for(my $i=0;$i<2000;$i++){
		$self->set_price($i);
	}

	for(my $i=2000;$i>1945;$i--){
		$self->set_price($i);
	}

	$self->_set_indicator($self->StochOsc());
	ok $self->should_sell(), "Market falling, should be selling";
#  print "status: " . $self->ticker_status() . "\n";

	$self->_set_indicator($self->StochFast());
	ok $self->should_sell(), "Market falling, should be selling";

	for(my $i=1900;$i>1700;$i--){
		$self->set_price($i);
	}

	$self->_set_indicator($self->Ma());
	ok $self->should_sell(), "Market falling, should be selling";

}


sub should_buy : Test(3)
{
	my $test = shift();
	my $self = $test->default_Ticker;

#set a downtrend then go up
	for(my $i=2000;$i>0;$i--){
		$self->set_price($i);
	}
	for(my $i=0;$i<115;$i++){
		$self->set_price($i);
	}

#  print "status: " . $self->ticker_status() . "\n";
	$self->_set_indicator($self->StochOsc());
	ok $self->should_buy(), "Market trending, should be buying";

	$self->_set_indicator($self->StochFast());
	ok $self->should_buy(), "Market trending, should be buying";

	for(my $i=116;$i<200;$i++){
		$self->set_price($i);
	}


	$self->_set_indicator($self->Ma());
	ok $self->should_buy(), "Market trending, should be buying";


}




1;

