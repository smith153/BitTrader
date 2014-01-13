
package Indicator::Ma;
use namespace::autoclean;
use Moose;
with 'Ewa';
with 'Indicator';

has 'avg' => (	is => 'ro', isa => 'Num', writer => '_set_avg',);
has 'avg_slow' => (	is => 'ro', isa => 'Num', writer => '_set_avg_slow',);
has 'avg_slower' => (	is => 'ro', isa => 'Num', writer => '_set_avg_slower',);
has 'avg_slowest' => (	is => 'ro', isa => 'Num', writer => '_set_avg_slowest',);


sub _update_indicator
{
  my ($self, $cur) = @_;
  my $avg;

  $avg = $self->avg();
  $avg = $self->ewa($cur,$avg,1/8);
  $self->_set_avg($avg);

  $avg = $self->avg_slow();
  $avg = $self->ewa($cur,$avg,1/32);
  $self->_set_avg_slow($avg);

  $avg = $self->avg_slower();
  $avg = $self->ewa($cur,$avg,1/64);
  $self->_set_avg_slower($avg);

  $avg = $self->avg_slowest();
  $avg = $self->ewa($cur,$avg,1/128);
  $self->_set_avg_slowest($avg);

}

sub should_buy
{
  my $self = shift();
  my $l    = $self->avg();
  my $ll   = $self->avg_slow();
  my $lll  = $self->avg_slower();
  my $llll = $self->avg_slowest();

  if($l > $ll and $ll > $lll and $lll > $llll){ #market trending
	return 1;
  }
  return 0;

}

sub should_sell
{
  my $self = shift();
  my $l    = $self->avg();
  my $ll   = $self->avg_slow();
  my $lll  = $self->avg_slower();
  my $llll = $self->avg_slowest();

  if($llll > $lll and $lll > $ll and $ll > $l){#market falling
	return 1;
  }
  return 0;

}



__PACKAGE__->meta->make_immutable;
1;
