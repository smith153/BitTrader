package BitTrader::Role::Averages;
use namespace::autoclean;
use Moose::Role;

has sequences => (
	is => 'ro',
	isa => 
);

sub ewa
{
  my ($self, $current, $last, $alpha) = @_;
  $last = $current if not defined $last;
  my $ewa = (1 - $alpha) * $last + $alpha * $current;
  return sprintf("%.2f",$ewa);
}





1;

__END__

=head1 NAME
BitTrader::Role::Averages
=head1 SYNOPSIS

	use BitTrader::Role::Averages

=head1 DESCRIPTION

Moose role to include averaging functions
L<http://en.wikipedia.org/wiki/Moving_average>

=head2 ewa

Return the exponential moving average
	ewa($current, $last, $alpha);
C<$current> is the current live value
C<$last> is the previous computed average (or undef for initial)
C<$alpha> is the weight. Use 2/(N+1) for values close to a C<sma> of N
	
=cut

