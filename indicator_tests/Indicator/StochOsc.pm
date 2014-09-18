
package Indicator::StochOsc;
use namespace::autoclean;
use Moose;
with 'Ewa';
with 'Indicator';

has '_stoch_que' => ( is =>'ro',  isa => 'ArrayRef[Num]', default => sub {[]} ,);

has 'stoch_size' => ( is => 'ro', isa => 'Int', default => 43200);

has '_above_80' => ( is =>'ro', isa => 'Int', writer => '_set_above_80',);

has '_below_20' => ( is =>'ro', isa => 'Int', writer => '_set_below_20',);

has 'k' => ( is => 'ro', isa => 'Num', writer => '_set_k',);

has 'd' => ( is => 'ro', isa => 'Num', writer => '_set_d',);



#1440, 43200

sub _update_indicator
{
  my ($self, $cur) = @_;
  my $k;
  my $k_avg = $self->k();
  my $d = $self->d();

  $k = $self->_stochOsc($cur);
  return if not defined $k;

  $k_avg = $self->ewa($k,$k_avg,1/6);

  $self->_set_k($k_avg);

  $d = $self->ewa($k,$d,1/16);
  $self->_set_d($d);

  $self->_set_limit();

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

sub _set_limit
{
  my $self = shift();
  if( $self->d() > 87){
	$self->_set_above_80(1);
  }
  if( $self->d() < 15){
	$self->_set_below_20(1);
  }

  #make sure both are not 1
  if($self->d() > 50){
	$self->_set_below_20(0);
  } 
  if($self->d() < 50){
	$self->_set_above_80(0);
  }
}

sub should_buy
{
  my $self = shift();

  if($self->k() > $self->d() and $self->d() < 30 and ($self->k() - $self->d() ) > 0.45){
  #if($self->k() > $self->d() and $self->_below_20 and $self->d() > 18){
	return 1;
  }
  return 0;

}

sub should_sell
{
  my $self = shift();

  #if($self->d() > $self->k() and $self->d() > 90 ){
  if($self->d() > $self->k() and $self->_above_80 and $self->d() < 80 ){
	return 1;
  }
  return 0;

}



__PACKAGE__->meta->make_immutable;
1;
