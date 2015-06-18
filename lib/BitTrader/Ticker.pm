package BitTrader::Ticker;
use Moose;
use BitTrader::Config;
use namespace::autoclean;
with 'MooseX::Log::Log4perl';



has 'symbol' => ( is => 'ro', isa => 'Str', required => '1', );

has 'amount' => ( is => 'rw', isa => 'Num',);

has 'price' => ( is => 'ro', isa => 'Num',writer => 'set_price', trigger => \&_update_indicators, );

has 'last_action' => ( is => 'rw', isa => 'Str', default => '0');

has 'cur_indicator' => (is => 'ro', does => 'BitTrader::Indicator', writer => '_set_indicator', );

has '_indicators' => (
	is => 'ro', 
	isa => 'HashRef[BitTrader::Indicator]', 
	traits  => ['Hash'],
	handles => {
		_add_indicator => 'set',
		_get_indicator => 'get',
		_list_indicators => 'keys',
		_indicator_valid => 'exists',
	}
);

has '_cfg' => (
	is => 'ro',
	isa => 'BitTrader::Config',
	default => sub { BitTrader::Config->new(); },
);



sub BUILD
{
  my $self = shift();


  foreach my $indicator (split( /,/,$self->_cfg->get_var('indicators')) ){
	my $module = "BitTrader::Indicator::$indicator";
	eval "require $module" or die $@;
	$self->_add_indicator($indicator => $module->new() );
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
  my $txt;
  my $old = ( $self->cur_indicator() ) ?  (split( /\:\:/, blessed $self->cur_indicator()))[2] : "";
  my $new = $self->_cfg->get_var('cur_indicator');

  return if ($old eq $new);

  $self->_set_indicator($self->_get_indicator($new));

  if(not $self->_indicator_valid($new) ){
	my $indicators = join(' ', $self->_list_indicators() );
	$self->log->error("Indicator does not match one of $indicators!");
  }
  else{
	$self->_set_indicator($self->_get_indicator($new));
  }

  $self->log->info("Indicator changed. Was $old, now is $new.");
}

sub _update_indicators
{
  my ($self, $cur) = @_;

  foreach my $indicator ($self->_list_indicators()){
	$self->_get_indicator($indicator)->set_price($cur);
  }
}


sub should_buy
{
  my $self = shift();
  if($self->cur_indicator()->should_buy and $self->last_action ne 'buy'){
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
  if($self->cur_indicator()->should_sell and $self->last_action ne 'sell'){
	return 1;
  }
  if(-e "/tmp/sell"){
	return 1;
  }
  return 0;
}




__PACKAGE__->meta->make_immutable;
1;

