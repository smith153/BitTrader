package BitTrader::Ticker;
use Moose;
use namespace::autoclean;
use BitTrader::Indicator::Ma;
use BitTrader::Indicator::StochOsc;
use BitTrader::Indicator::StochFast;
use BitTrader::Config;
with 'MooseX::Log::Log4perl';



has 'symbol' => ( is => 'ro', isa => 'Str', required => '1', );

has 'amount' => ( is => 'rw', isa => 'Num',);

has 'price' => ( is => 'ro', isa => 'Num',writer => 'set_price', trigger => \&_update_indicators, );

has 'last_action' => ( is => 'rw', isa => 'Str', default => '0');

has '_file' => ( is => 'ro', isa => 'Str', default => '/tmp/.indicator2');

has 'indicator' => (is => 'ro', does => 'BitTrader::Indicator', writer => '_set_indicator', );

has 'Ma' => ( is => 'ro', isa => 'BitTrader::Indicator::Ma', writer => '_set_Ma', 
	handles =>{
		avg => 'avg',
		avg_slow => 'avg_slow',
		avg_slower => 'avg_slower',
		avg_slowest => 'avg_slowest',
	},
);

has 'StochOsc' => (is => 'ro', isa => 'BitTrader::Indicator::StochOsc', writer => '_set_StochOsc', 
	handles => {
		k => 'k',
		d => 'd',
	},
);

has 'StochFast' => (is => 'ro', isa => 'BitTrader::Indicator::StochFast', writer => '_set_StochFast', 
	handles => {
		k_fast => 'k',
		d_fast => 'd',
	},
);

has '_cfg' => (
	is => 'ro',
	isa => 'BitTrader::Config',
	writer => '_set_cfg',
);



sub BUILD
{
  my $self = shift();
  my $file = $self->_file();
  if(not -e $file){
	open(my $fh, ">$file");
	print $fh "StochFast";
	close($fh);
  }
	$self->_set_cfg(BitTrader::Config->new() );
#  $self->_set_indicator(" ");

  $self->_set_Ma( BitTrader::Indicator::Ma->new() );
  $self->_set_StochOsc( BitTrader::Indicator::StochOsc->new() );
  if($self->symbol() eq 'btc'){
	$self->_set_StochFast( BitTrader::Indicator::StochFast->new(stoch_size => 165) );
  }
  elsif($self->symbol eq 'ltc'){
	$self->_set_StochFast( BitTrader::Indicator::StochFast->new(stoch_size => 244) );
  }
  $self->get_indicator();
}

sub ticker_status
{ 
  my $self = shift();
  my $txt = "\n\tSym: ${\$self->symbol()}\n\tAmount: ${\$self->amount()}\n\tCurr price: ${\$self->price()}\n\tAverages: " .
		"${\$self->avg()} ${\$self->avg_slow()} ${\$self->avg_slower()} ${\$self->avg_slowest()}\n\tK: ${\$self->k()} D: ${\$self->d()}" .
		"\n\tK_fast: ${\$self->k_fast()} D_fast: ${\$self->d_fast()}\n\tTotal value: \$" . int($self->amount() * $self->price() ). "\n\tLast_ac: ${\$self->last_action()}\n\n";
  return $txt;
}


sub get_indicator
{
  my $self = shift();
  my $file = $self->_file();
  my $txt;
  my $old = ( $self->indicator() ) ?  blessed $self->indicator() : "";
  my $new;
  open(my $fh, "<$file");
  $txt = <$fh>;
  chomp($txt);
  if($txt !~ /Ma|StochOsc|StochFast/){
	$self->log->error("Indicator does not match ma or stoch! Forcing StochFast!");
	$self->_set_indicator($self->StochFast() );
  }
  else{
	if($txt eq 'StochOsc'){
		$self->_set_indicator($self->StochOsc() );
	}
	elsif($txt eq 'Ma'){
		$self->_set_indicator($self->Ma() );
	}
	elsif($txt eq 'StochFast'){
		$self->_set_indicator($self->StochFast() );
	}

  }
  $new = blessed $self->indicator();
  if($old ne $new and $old ne ""){
	$self->log->info("Indicator changed. Was $old, now is $new.");
  }
}

sub _update_indicators
{
  my ($self, $cur) = @_;
  $self->StochOsc()->set_price($cur);
  $self->StochFast()->set_price($cur);
  $self->Ma()->set_price($cur);
}




sub should_buy
{
  my $self = shift();
  if($self->indicator()->should_buy and $self->last_action ne 'buy'){
	return 1;
  }
  if(-e "/tmp/buy"){
	return 1;
  }
  return 0;
}

sub should_sell
{
  my $self = shift();
  if($self->indicator()->should_sell and $self->last_action ne 'sell'){
	return 1;
  }
  if(-e "/tmp/sell"){
	return 1;
  }
  return 0;
}




__PACKAGE__->meta->make_immutable;
1;

