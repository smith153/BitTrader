
package Indicator::StochRsi2;
use namespace::autoclean;
use Data::Dumper;
use Moose;
with 'Ewa';
with 'Indicator';

has '_stoch_que' => ( is =>'ro',  isa => 'ArrayRef[Num]', default => sub {[]} ,);

has 'stoch_size' => ( is => 'ro', isa => 'Int', default => 500);

has '_up_que' => ( is => 'ro', isa => 'ArrayRef[Num]', default => sub {[]},);

has '_down_que' => ( is => 'ro', isa => 'ArrayRef[Num]', default => sub {[]},);

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
  my $size = $self->stoch_size() / 3;
  my $gain;
  my $rsi;
  my $rs;
  my $up_arr = $self->_up_que();
  my $down_arr = $self->_down_que();
  my $up_ewa;
  my $down_ewa;
  my $up_total = 0;
  my $down_total = 0;

  return unless $last;

  foreach my $item (@{$up_arr}){
	$up_total += $item;
  }
  foreach my $item (@{$down_arr}){
	$down_total += $item;
  }

  if(@{$up_arr} > 2){
	$up_ewa = $up_total / scalar @{$up_arr};
	$down_ewa = $down_total / scalar @{$down_arr};
  }
#print "up_avg: $up_ewa down_avg: $down_ewa ";

  $gain = $cur - $last;
#print "cur: $cur last: $last gain: $gain ";
  if($gain > 0){
	push(@{$up_arr},$gain);
	push(@{$down_arr},0);
  }
  elsif($gain < 0){
	$gain = abs $gain;
	push(@{$down_arr},$gain);
	push(@{$up_arr},0);
  }
  else{
	push(@{$down_arr},0);
	push(@{$up_arr},0);
  }

  if(@{$up_arr} > $size){
	shift @{$up_arr};
  }
  if(@{$down_arr} > $size){
	shift @{$down_arr};
  }

  return if(@{$up_arr} < 5);

  $up_ewa = (($up_ewa * ($size-1)) + $up_arr->[@{$up_arr}-1]) / $size;
  $down_ewa = (($down_ewa * ($size-1)) + $down_arr->[@{$down_arr}-1]) / $size;

#print "cur up gain: " . $up_arr->[@{$up_arr}-1] . " up_ewa: $up_ewa down_ewa: $down_ewa ";

  return if $down_ewa == 0;

  $rs = $up_ewa/$down_ewa;
#print "rs: $rs ";
  $rsi = 100 - (100/(1+$rs));
  $rsi = sprintf("%.2f",$rsi);
#print "rsi: $rsi\n";
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
