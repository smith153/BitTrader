package BitTrader::Indicator;
use Moose::Role;
use namespace::autoclean;



has 'price' => ( is => 'ro', isa => 'Num',writer => 'set_price', trigger => \&_update, );

requires '_update_indicator';
requires 'should_buy';
requires 'should_sell';

sub _update
{
  my ($self,$cur, $last) = @_;
  $self->_update_indicator($cur,$last);
}

1;
