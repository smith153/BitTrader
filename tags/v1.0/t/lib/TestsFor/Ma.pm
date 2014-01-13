package TestsFor::Indicator::Ma;
use Test::Most;
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
		avg => 5,
		avg_slow => 4,
		avg_slower => 3,
		avg_slowest => 2,
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

sub my_methods : Test(3)
{
  my $test = shift();
  my $class = $test->class_to_test();
  can_ok $class, '_update_indicator';
  can_ok $class, 'should_buy';
  can_ok $class, 'should_sell';
}

sub should_sell : Test(1)
{
  my $test = shift();
  my $self = $test->default_Ma;
  is $self->should_sell, 0, "Market trending, we shouldn't sell";
}

sub should_buy : Test(1)
{
  my $test = shift();
  my $self = $test->default_Ma;
  is $self->should_buy, 1, "Market trending, we should buy";
}

sub price : Test(4)
{
  my $test = shift();
  my $self = $test->default_Ma();
  my $avg = $self->avg();
  my $avg_slow = $self->avg_slow();
  ok( (not $self->price()),"Price shouldn't be set");
  $self->set_price(10);
  is $self->price, 10, "Price is 10";
  ok $self->avg != $avg, "Average needs to change";
  ok $self->avg_slow != $avg_slow, "Average_slow needs to change";
  
}

1;
