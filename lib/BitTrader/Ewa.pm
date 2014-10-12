package BitTrader::Ewa;
use namespace::autoclean;
use Moose::Role;


sub ewa
{
  my ($self, $current, $last, $alpha) = @_;
  $last = $current if not defined $last;
  my $ewa = (1 - $alpha) * $last + $alpha * $current;
  return sprintf("%.2f",$ewa);
}



1;
