package BitTrader::Indicator::StochOsc;
use namespace::autoclean;
use Moose;
use Math::Sma;
with 'BitTrader::Indicator';

has '_stoch_que' => ( is =>'ro',  isa => 'ArrayRef[Num]', default => sub {[]} ,);

has 'stoch_size' => ( is => 'ro', isa => 'Int', default => 1440);

has 'k' => ( is => 'ro', isa => 'Num', writer => '_set_k',);

has 'd' => ( is => 'ro', isa => 'Num', writer => '_set_d',);

has '_d_avg' => ( is => 'ro', isa => 'Math::Sma',
	default => sub {return Math::Ewa->new(size => 11)},
);





sub _update_indicator
{
  my ($self, $cur) = @_;
  my $k;
  my $d = $self->d();

  $k = $self->_stochOsc($cur);
  return if not defined $k;

  $self->_set_k($k);

  $self->_set_d($self->_d_avg->sma($k));

}




sub _stochOsc
{ 
  my ($self,$cur) = @_;
  my $que = $self->_stoch_que();
  my $high;
  my $low;
  my $k;
  my $size = $self->stoch_size();

  if($cur < 1){
        return;
  }     

  push(@{$que},$cur);
  if(@{$que} < $size){
        return;
  }
  if(@{$que} > $size){
        shift @{$que};
  }
  foreach my $item (@{$que}){
	$high = $item unless defined $high;
	$low = $item unless defined $low;
	if($item > $high){
		$high = $item;
	}      
	if($item < $low){
		$low = $item;
	}
  }

  $k = 100*(($cur-$low)/($high-$low));
  return sprintf("%.2f",$k);
}


sub should_buy
{
  my $self = shift();

  if($self->k() > $self->d() and $self->d() < 30 ){
	return 1;
  }
  return 0;

}

sub should_sell
{
  my $self = shift();

  if($self->d() > $self->k() and $self->d() > 90 ){
	return 1;
  }
  return 0;

}



__PACKAGE__->meta->make_immutable;
1;
