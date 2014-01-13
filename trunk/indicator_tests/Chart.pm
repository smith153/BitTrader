
package Chart;
use namespace::autoclean;
use Moose;
use local::lib;
use WebService::Plotly;

use Data::Dumper;


has url => (is => 'ro', isa => 'Str', writer => '_set_url',);

has plotly => (is => 'ro', isa => 'WebService::Plotly', writer => '_set_plotly', 
	handles => {
		plot => 'plot',
		},
	);

has chart => (is => 'ro', isa => 'ArrayRef[Str]',);


sub BUILD
{
  my $self = shift();
  my $user = 'xxx';
  my $key = 'xxxx';
  my $plotly = WebService::Plotly->new( un => $user, key => $key );
  $self->_set_plotly($plotly);


}

sub _init_chart
{
  my ($self, @arr) = @_;
  my $chart;
  my $ref;
  for(my $i = 0; $i < @arr - 1; $i++){
	if($i >= 2){
		$ref = {x => [], y => [], yaxis => 'y2'};
	}
	else{
		$ref = {x => [], y => []};
	}

	push(@{$chart},$ref);
  }
  return $chart;
}

sub convert
{
  my $self = shift();
  my @date;
  my $chart;
#a  my @data = ("2013-12-01 07:35:09,34.40,34.18,62.77,62.54", 
#	"2013-12-01 09:40:49,33.49,34.02,60.34,60.69");
  while(my $ele = shift(@{$self->chart})){
#  while(my $ele = shift(@data)){
	my @arr = split(/,/,$ele);
	$chart = $self->_init_chart(@arr) unless $chart;
	push(@date,shift(@arr));
	foreach my $ref (@{$chart}){
		$ref->{x} = \@date;
		push(@{$ref->{y}},shift @arr);
	}
  }
my $layout= {
'yaxis'=> {'domain'=> [1/2,1], title => 'Ticker'}, 
'yaxis2'=> {'domain'=> [0,1/2], title => 'Indicator'},
#'yaxis3'=> {'domain'=>[1/2,1]},
#'#yaxis4'=> {'domain'=>[1/2,1]},
'legend'=> {'traceorder'=> 'reversed'},
height => 700, 
width => 1500,
borderwidth =>  5,
};
#print Dumper $chart;
#print "#######\n\n\n";
#print Dumper $chart;
my $response = $self->plot($chart, layout=>$layout);

  print Dumper $response;
}



__PACKAGE__->meta->make_immutable;
