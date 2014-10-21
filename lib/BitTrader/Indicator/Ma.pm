package BitTrader::Indicator::Ma;
use namespace::autoclean;
use Moose;
use Math::Ewa;
with 'BitTrader::Indicator';

has 'avg' => (	is => 'ro', isa => 'Math::Ewa',
	default => sub {return Math::Ewa->new(alpha => 1/8)},
);
has 'avg_slow' => (	is => 'ro', isa => 'Math::Ewa',
	default => sub {return Math::Ewa->new(alpha => 1/16)},
);
has 'avg_slower' => (	is => 'ro', isa => 'Math::Ewa',
	default => sub {return Math::Ewa->new(alpha => 1/32)},
);
has 'avg_slowest' => (	is => 'ro', isa => 'Math::Ewa',
	default => sub {return Math::Ewa->new(alpha => 1/128)},
);


sub _update_indicator
{
	my ($self, $cur) = @_;

	$self->avg->ewa($cur);
	$self->avg_slow->ewa($cur);
	$self->avg_slower->ewa($cur);
	$self->avg_slowest->ewa($cur);

}

sub should_buy
{
	my $self = shift();
	my $l    = $self->avg->last_avg();
	my $ll   = $self->avg_slow->last_avg();
	my $lll  = $self->avg_slower->last_avg();
	my $llll = $self->avg_slowest->last_avg();

	if($l > $ll and $ll > $lll and $lll > $llll){ #market trending
		return 1;
	}
	return 0;

}

sub should_sell
{
	my $self = shift();
	my $l    = $self->avg->last_avg();
	my $ll   = $self->avg_slow->last_avg();
	my $lll  = $self->avg_slower->last_avg();
	my $llll = $self->avg_slowest->last_avg();

	if($llll > $lll and $lll > $ll and $ll > $l){#market falling
		return 1;
	}
	return 0;

}

sub status
{
	my $l    = sprintf("%.2f", $self->avg->last_avg() );
	my $ll   = sprintf("%.2f", $self->avg_slow->last_avg() );
	my $lll  = sprintf("%.2f", $self->avg_slower->last_avg() );
	my $llll = sprintf("%.2f", $self->avg_slowest->last_avg() );

	return "Averages (fastest to slowest): $l, $ll, $lll, $llll\n";
}

__PACKAGE__->meta->make_immutable;
1;
