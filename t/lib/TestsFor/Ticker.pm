package TestsFor::BitTrader::Ticker;
use Test::Most;
use base 'TestsFor';
use Data::Dumper;


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

	open(my $fh, ">config") or die "Couldn't create file 'config' $!\n";
	print $fh "cur_indicator = StochFast\nindicators = StochFast,StochOsc,Ma\n";
	close($fh);

	my $cfg = BitTrader::Config->new(_file => 'config');
	

	$test->default_Ticker( $test->class_to_test->new(
		symbol => 'ltc',
		_cfg => $cfg,
		)
	);


} 

sub teardown : Tests(teardown) 
{
	my $test = shift();
	my $self = $test->default_Ticker();
	$test->SUPER::setup();

	unlink $self->_cfg->_file();
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
	can_ok $class, "_indicators";
	can_ok $class, "cur_indicator";
	can_ok $class, "_cfg";
}

sub my_methods : Test(9)
{
	my $test = shift();
	my $class = $test->class_to_test();
	can_ok $class, 'ticker_status';
	can_ok $class, 'switch_indicator';
	can_ok $class, '_update_indicators';
	can_ok $class, 'should_buy';
	can_ok $class, 'should_sell';
	can_ok $class, '_add_indicator';
	can_ok $class, '_get_indicator';
	can_ok $class, '_list_indicators';
	can_ok $class, '_indicator_valid';
}

sub switch_indicator : Test(3)
{
	my $test = shift();
	my $self = $test->default_Ticker;

	$self->_cfg->set_var("cur_indicator", "StochOsc");
	$self->switch_indicator();
	is ref($self->cur_indicator()), "BitTrader::Indicator::StochOsc", "Indicator should be StochOsc";

	$self->_cfg->set_var("cur_indicator", "Ma");
	$self->switch_indicator();
	is ref($self->cur_indicator()), "BitTrader::Indicator::Ma", "Indicator should be Ma";

	$self->_cfg->set_var("cur_indicator", "StochFast");
	$self->switch_indicator();
	is ref($self->cur_indicator()), "BitTrader::Indicator::StochFast", "Indicator should be StochFast";

}

sub _update_indicators : Test(4)
{
	my $test = shift();
	my $self = $test->default_Ticker;

	$self->_update_indicators(111);

	is $self->cur_indicator()->price(), 111, "Indicator should be 111";

	foreach my $indicator ($self->_list_indicators() ){
		my $type = ref $self->_get_indicator($indicator);
		is $self->_get_indicator($indicator)->price(), 111, "$type should be at 111";
	}
}



sub should_sell : Test(2)
{
	my $test = shift();
	my $self = $test->default_Ticker;

	for(my $i=0;$i<200;++$i){
		$self->set_price($i);
	}

	for(my $i=200;$i>50;--$i){
		$self->set_price($i);
	}

	$self->_cfg->set_var("cur_indicator", "Ma");
	$self->switch_indicator();

	ok $self->should_sell(), "Market falling, should be wanting to sell";
	ok !$self->should_buy(), "Market falling, should not be wanting to buy";
}


sub should_buy : Test(2)
{
	my $test = shift();
	my $self = $test->default_Ticker;

	#set a downtrend then go up
	for(my $i=200;$i>0;--$i){
		$self->set_price($i);
	}
	for(my $i=0;$i<150;++$i){
		$self->set_price($i);
	}

	$self->_cfg->set_var("cur_indicator", "Ma");
	$self->switch_indicator();

	ok !$self->should_sell(), "Market trending, should not be wanting to sell";
	ok $self->should_buy(), "Market trending, should be wanting to buy";

}




1;

