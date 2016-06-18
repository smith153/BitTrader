package BitTrader::Indicator::Ma;
use namespace::autoclean;
use Moose;
use Math::EWMA;
with 'BitTrader::Indicator';

has 'avg' => (	is => 'ro', isa => 'Math::EWMA',
	default => sub {return Math::EWMA->new(alpha => 1/8)},
);
has 'avg_slow' => (	is => 'ro', isa => 'Math::EWMA',
	default => sub {return Math::EWMA->new(alpha => 1/16)},
);
has 'avg_slower' => (	is => 'ro', isa => 'Math::EWMA',
	default => sub {return Math::EWMA->new(alpha => 1/32)},
);
has 'avg_slowest' => (	is => 'ro', isa => 'Math::EWMA',
	default => sub {return Math::EWMA->new(alpha => 1/128)},
);


sub _update_indicator
{
	my ($self, $cur) = @_;

	$self->avg->ewma($cur);
	$self->avg_slow->ewma($cur);
	$self->avg_slower->ewma($cur);
	$self->avg_slowest->ewma($cur);

}

sub should_buy
{
	my $self = shift();
	my $l    = $self->avg->ewma();
	my $ll   = $self->avg_slow->ewma();
	my $lll  = $self->avg_slower->ewma();
	my $llll = $self->avg_slowest->ewma();

	if($l > $ll and $ll >  $lll){ #market trending
		return 1;
	}
	return 0;

}

sub should_sell
{
	my $self = shift();
	my $l    = $self->avg->ewma();
	my $ll   = $self->avg_slow->ewma();
	my $lll  = $self->avg_slower->ewma();
	my $llll = $self->avg_slowest->ewma();

	if( $lll > $ll and $ll > $l){#market falling
		return 1;
	}
	return 0;

}

sub status
{
	my $self = shift();
	my $l    = sprintf("%.2f", $self->avg->ewma() );
	my $ll   = sprintf("%.2f", $self->avg_slow->ewma() );
	my $lll  = sprintf("%.2f", $self->avg_slower->ewma() );
	my $llll = sprintf("%.2f", $self->avg_slowest->ewma() );

	return "Averages (fastest to slowest): $l, $ll, $lll, $llll\n";
}

__PACKAGE__->meta->make_immutable;
1;
