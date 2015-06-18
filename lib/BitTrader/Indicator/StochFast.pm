package BitTrader::Indicator::StochFast;
use Moose;
use Math::SMA;
use namespace::autoclean;
with 'BitTrader::Indicator';

has '_stoch_que' => ( is =>'ro',  isa => 'ArrayRef[Num]', default => sub {[]} ,);

has 'stoch_size' => ( is => 'ro', isa => 'Int', default => 165);

has 'k' => ( is => 'ro', isa => 'Num', writer => '_set_k',);

has 'd' => ( is => 'ro', isa => 'Num', writer => '_set_d',);

has '_k_avg' => ( is => 'ro', isa => 'Math::SMA',
	default => sub {return Math::SMA->new(size => 3)},
);

has '_d_avg' => ( is => 'ro', isa => 'Math::SMA',
	default => sub {return Math::SMA->new(size => 31)},
);



#ltc: 244
#btc: 110,160,170
#btc: 165

sub _update_indicator
{
  my ($self, $cur, $last) = @_;

  $self->_stochOsc($cur);

}




sub _stochOsc
{ 
  my ($self,$cur) = @_;
  my $que = $self->_stoch_que();
  my $high;
  my $low;
  my $k;
  my $d;
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

  $self->_set_k($self->_k_avg->sma($k));
  $self->_set_d($self->_d_avg->sma($k));

}



sub should_buy
{
  my $self = shift();

  if($self->k() > $self->d() and $self->d > 68  and $self->d() < 72  ){
	return 1;
  }
  return 0;

}

sub should_sell
{
  my $self = shift();

  if($self->d() > $self->k()  and $self->d() > 80 and $self->k() < 75){
	return 1;
  }
  return 0;

}

sub status
{
	my $self = shift();
	return "StockFast status: K: ${\$self->k} D: ${\$self->d}\n";
}


__PACKAGE__->meta->make_immutable;
1;
