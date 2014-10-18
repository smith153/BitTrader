package Math::Sma;
use Moose;
use namespace::autoclean;

has size => (
	is =>'ro',
	isa => 'Int',
	required => '1',
);

has last_avg => (
	is =>'ro',
	isa => 'Num',
	writer => '_set_last_avg',
);

has _values => (
    is => 'ro',
    isa => 'ArrayRef[Num]',
	default => sub { [] },
	traits  => ['Array'],
	handles => {
		_push_value => 'push',
		_shift_value => 'shift',
	},
);


sub sma
{
	my ($self, $current) = @_;
	my $last = $self->last_avg();
	my $values = $self->_values();
	my $size = $self->size();
	my $avg;
	

	$self->_push_value($current);

	#return simple avg if not enough periods
	if(@{$values} < $size){
		return sprintf("%.2f", $self->_raw_average());
	}

	if( not defined $last ){
		$self->_set_last_avg($self->_raw_average());
		return sprintf("%.2f", $self->last_avg());
	}

	my $obsolete = $self->_shift_value();
	$avg = $last - ($obsolete/$size) + ($current/$size);
	$self->_set_last_avg($avg);

	return sprintf("%.2f", $avg);
}


sub _raw_average
{
	my $self = shift();
	my $size = @{$self->_values()} || 1;
	my $total = 0;
	foreach (@{$self->_values}){
		$total += $_;
	}
	return $total / $size;
}




__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Math::Sma

=head1 SYNOPSIS

    use Math::Sma;
	my $sma = Math::Sma->new(size => $n);
	$sma->sma($value);

=head1 DESCRIPTION

Implements a simple moving average of N periods
L<http://en.wikipedia.org/wiki/Moving_average>

=head2 new

Create a new Sma object of C<$n> periods.
	my $sma = Math::Sma->new($n);

=head2 sma

Return the current moving average
    sma($current);
C<$current> is the current live value
    
=cut

 
