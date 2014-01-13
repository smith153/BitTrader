
package Indicator::StochRsi;
use namespace::autoclean;
use Moose;
with 'Ewa';
with 'Indicator';

has '_stoch_que' => ( is =>'ro',  isa => 'ArrayRef[Num]', default => sub {[]} ,);

has 'stoch_size' => ( is => 'ro', isa => 'Int', default => 160);

has '_up_ewa' => ( is => 'ro', isa => 'Num', writer => '_set_up_ewa',);

has '_down_ewa' => ( is => 'ro', isa => 'Num', writer => '_set_down_ewa',);

has '_above_80' => ( is =>'ro', isa => 'Int', writer => '_set_above_80',);

has '_below_20' => ( is =>'ro', isa => 'Int', writer => '_set_below_20',);

has 'rsi' => ( is => 'ro', isa => 'Num', writer => '_set_rsi',);

has 'k' => ( is => 'ro', isa => 'Num', writer => '_set_k',);

has 'd' => ( is => 'ro', isa => 'Num', writer => '_set_d',);





sub _update_indicator
{
  my ($self, $cur, $last) = @_;
  my $rsi;

  $rsi = $self->_rsi($cur,$last);
  return unless $rsi;
  $self->_stochRsi($self->rsi());

}

sub _rsi
{
  my ($self,$cur,$last) = @_;
  my $alpha = 2/($self->stoch_size()+1);
  my $gain;
  my $rsi;
  my $rs;
  my $up_ewa = $self->_up_ewa();
  my $down_ewa = $self->_down_ewa();
print "cur: $cur last: $last alpha: $alpha ";
  return unless $last;
  $gain = $cur - $last;
print "gain: $gain ";
  if($gain > 0){
	$up_ewa = $self->ewa($gain,$up_ewa,$alpha);
	$down_ewa = $self->ewa(0,$down_ewa,$alpha);
  }
  elsif($gain < 0){
	$gain = abs $gain;
	$down_ewa = $self->ewa($gain,$down_ewa,$alpha);
	$up_ewa = $self->ewa(0,$up_ewa,$alpha);
  }
  else{
	$up_ewa = $self->ewa(0,$up_ewa,$alpha);
	$down_ewa = $self->ewa(0,$down_ewa,$alpha);
  }

  $self->_set_up_ewa($up_ewa) if $up_ewa;
  $self->_set_down_ewa($down_ewa) if $down_ewa;
print "upgain: $up_ewa downgain: $down_ewa ";
  return unless $up_ewa > 0 and $down_ewa > 0;

  $rs = $up_ewa/$down_ewa;
print "rs: $rs ";
  $rsi = 100 - (100/(1+$rs));
  $rsi = sprintf("%.2f",$rsi);
print "rsi: $rsi\n";
  $self->_set_rsi($rsi);
  return $rsi;
}


sub _stochRsi
{ 
  my ($self,$cur) = @_;
  my $que = $self->_stoch_que();
  my $high;
  my $low;
  my $k;
  my $d = $self->d();
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
  $k = sprintf("%.2f",$k);
  $d = $self->ewa($k,$d,1/6);
  
  $self->_set_k($k);
  $self->_set_d($d);

  $self->_set_limit();
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

  if($self->k() > $self->d() and $self->_below_20 and $self->d() > 18 ){
	return 1;
  }
  return 0;

}

sub should_sell
{
  my $self = shift();

  if($self->d() > $self->k() and $self->_above_80 and $self->d() < 80 ){
	return 1;
  }
  return 0;

}



__PACKAGE__->meta->make_immutable;
1;
