package Math::Ewa;
use Moose;
use namespace::autoclean;


has alpha => (
	is =>'ro',
	isa => 'Num',
	required => '1',
);

has last_avg => (
	is =>'ro',
	isa => 'Num',
	writer => '_set_last_avg',
);



sub ewa
{
	my ($self, $current) = @_;
	my $last = $self->last_avg();
	my $alpha = $self->alpha();

	$last = $current if not defined $last;
	my $ewa = (1 - $alpha) * $last + $alpha * $current;
	$self->_set_last_avg($ewa);
	return sprintf("%.2f",$ewa);
}




__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME
Math::Ewa
=head1 SYNOPSIS

    use Math::Ewa;
	my $ewa = Math::Ewa->new(alpha => $n);
	$ewa->ewa($value);

=head1 DESCRIPTION

Implements a exponential moving average with a weight of C<$alpha>
L<http://en.wikipedia.org/wiki/Moving_average>

=head2 new
Create a new Ewa object with alpha C<$n>.
	my $ewa = Math::Ewa->new($n);
An alpha value of 2/(N+1) is roughly equivalent to a simple moving average of N periods
=head2 ewa

Return the current exponential moving average
    ewa($current);
C<$current> is the current live value
    
=cut

 
