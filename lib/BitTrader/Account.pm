package BitTrader::Account;

use namespace::autoclean;
use Moose;
#use Email::Sender::Simple;
use Finance::btce;
use Data::Dumper;
use BitTrader::Ticker;
use BitTrader::Config;
with 'MooseX::Log::Log4perl';
with 'BitTrader::DB_Handle';


has 'symbols' => (
	is => 'ro',
	isa => 'ArrayRef[Str]',
	required => '1',
);
has '_funds' => (
	is => 'rw',
	isa => 'HashRef[Num]',
	traits => ['Hash'],
	handles => {
		_get_fund => 'get',
		_set_funds => 'set',
	},
);
has '_btce' => (
	is => 'ro',
	isa => 'Finance::btce',
	writer => '_set_btce',
	handles => {
		_getTicker => 'getTicker',
		_getInfo => 'getInfo',
		_trade => 'trade',
		_cancelOrder => 'cancelOrder',
		_activeOrders => 'activeOrders',
	},
);

has '_tickers' => (
	is => 'ro',
	isa => 'ArrayRef[BitTrader::Ticker]',
	traits => ['Array'],
	handles => {
		_set_ticker => 'push'
	},
);

has '_cfg' => (
	is => 'ro',
	isa => 'BitTrader::Config',
	writer => '_set_cfg',
);

has 'noload' => ( is => 'ro', isa => 'Int', default => 0);

sub BUILD
{
	my $self = shift();

	$self->_set_cfg(BitTrader::Config->new() );

	if(not defined $self->_btce() ){
		$self->_set_btce(Finance::btce->new({
			apikey => $self->_cfg->get_var("apikey"),
			secret => $self->_cfg->get_var("apisecret"),
			})
		);
	}
	$self->_get_funds() or die;

	$self->_load_tickers();

	return;
}

sub poll
{
	my $self = shift();
	my $ref;
	my $return = 0;
	foreach my $t (@{$self->_tickers()}){
		$self->log->info("Getting price for ". $t->symbol());
		$ref = $self->_getTicker($t->symbol() . "_usd");
		if(not defined $ref or not $ref->{last} > 0){
			$self->log->error("Could not get ticker for " . $t->symbol());
			$return = 1;
			last;
		}
		$t->set_price($ref->{last});
		$self->log->info($t->ticker_status());
		if($t->should_buy){#TODO:  catch failed sales!
			next if( not defined $self->_buy($t,$ref) );
		}
		elsif($t->should_sell){
			next if( not defined $self->_sell($t,$ref) );
		}
		$t->get_indicator();
	}
	return $return;
}

sub _buy
{
	my ($self,$t,$cur_price) = @_;
	my $sym = $t->symbol();
	$self->_get_funds();
	my $amount;
	my $amount_usd = $self->_get_fund('usd') - 0.01;
	my $return;
	my $price = sprintf("%.3f",(($cur_price->{last} + $cur_price->{buy} + $cur_price->{sell}) / 3) + 0.1 );
	my $variance = abs 100-($price*100/$cur_price->{buy});

	$self->log->info("Buying $sym at $price");

	if($variance > 1.5){
		$self->log->error("Something wrong, variance is $variance%! Amount: $amount Price: $price Last: ". 
				"$cur_price->{last} Buy: $cur_price->{buy} Sell: $cur_price->{sell}");
		return;
	}

	if($amount_usd < 5){
		$self->log->error("Not enough USD, only have \$$amount_usd ?");
		$t->last_action('buy');
		return;
	}

	$amount = $self->_get_buy_amount($t,$price,$amount_usd);

	if(not defined $amount){
		$self->log->error("amount is undefined. Why?");
		return;
	}

	if($amount < 0.1){
		$self->log->error("Amount is $amount, needs to be greater than 0.1!");
		$t->last_action('buy');
		return;
	}

	$amount = sprintf("%0.6f",$amount);

	$self->log->info("Buying $amount $sym at $price. Total: \$" . $amount*$price);

	$return = $self->_trade($sym."_usd","buy",$price,$amount );
	if(not defined $return or $return->{success} != 1){
		$self->log->error("Could not buy!");
		$self->log->error($return->{error}) if( defined $return and exists $return->{error});
		return;
	}
	$t->order_id($return->{return}->{order_id});

	$self->_wait_on_market($t,$price,$amount,$amount_usd,"buy");

#  return $return;
}

sub _sell
{
	my ($self,$t,$cur_price, $o_amount) = @_;
	my $sym = $t->symbol();
	$self->_get_funds();
	my $amount = $self->_get_fund($sym);
	my $amount_usd = $self->_get_fund('usd');
	$amount = $o_amount if $o_amount;
	my $return;
	my $price = sprintf("%.3f", (($cur_price->{last} + $cur_price->{buy} + $cur_price->{sell}) / 3) - 0.1);
	my $variance = abs 100-($price*100/$cur_price->{sell});

	$self->log->info("Selling $amount $sym at $price. Total: \$" . $amount*$price);

	if($variance > 1.5){
		$self->log->error("Something wrong, variance is $variance%! Amount: $amount Price: $price Last: ". 
				"$cur_price->{last} Buy: $cur_price->{buy} Sell: $cur_price->{sell}");
		return;
	}

	if($amount < 0.1){
		$self->log->error("Amount is $amount, needs to be greater than 0.1!");
		$t->last_action('sell');
		return;
	}


	$return = $self->_trade($sym."_usd","sell",$price,$amount );
	if(not defined $return or $return->{success} != 1){
		$self->log->error("Could not sell!");
		$self->log->error($return->{error}) if( defined $return and exists $return->{error});
		return;
	}
	$t->order_id($return->{return}->{order_id});

	$self->_wait_on_market($t,$price,$amount,$amount_usd,"sell");

#  return $return;
}

sub _wait_on_market
{
	my ($self, $t, $price, $amount, $amount_usd, $action) = @_;
	my $sym = $t->symbol();
	my $return;

	for(my $i = 0; $i < 10;$i++){
		$self->log->info("Order is on market, sleeping.");
		sleep 10;
		$return = $self->_activeOrders();
		if(not defined $return){
			$self->log->error("Could not get active orders. ");
			next;
		}

		if(not defined $return->{'return'}->{$t->order_id()}){
			if($action eq "sell"){
				$self->log->info("Sold $amount $sym for $price. Total: \$" . $price*$amount);
				$t->last_action("sell");
				$t->amount( $t->amount() - $amount ); 
				$self->_get_funds();
				$self->_check_sell_amount($price,$amount,$amount_usd);
			}
			elsif($action eq "buy"){
				$self->log->info("Bought $amount $sym for $price. Total: \$". $price*$amount);
				$t->last_action("buy");
				$self->_get_funds();
				$self->_check_buy_amount($t,$price,$amount,$amount_usd);
				$t->amount( $self->_get_fund($sym) ); #update after checking what it should be.
			}
			last;
		}
	}
	$return = $self->_activeOrders();
	if(not defined $return){
		$self->log->error("Could not get active orders. ");
		return;
	}

	if(defined $return->{'return'}->{$t->order_id()}){
		$self->log->error("Order id: ${\$t->order_id()} too long on market, canceling.");
		my $cancel = $self->_cancelOrder($t->order_id() );
		if(not defined $cancel){
			$self->log->error("Couldn't cancel order!");
			return;
		}
		else{
			$self->_check_after_cancel($t, $price, $amount, $amount_usd, $action);
		}
	}
}

sub _check_buy_amount
{
	my ($self,$t,$price,$amount,$amount_usd) = @_;
	my $usd = $amount_usd - ($price * $amount); #usd that we calculate we should have
	my $usd_actual = $self->_get_fund('usd') - 0.01;  #usd that we have in our account
	my $coin = $t->amount() + $amount;
	my $variance = abs 100-($usd*100/$usd_actual);
	my $variance2 = abs 100-($coin*100/$self->_get_fund($t->symbol()) );
	$self->log->info("Checking if buy order was processed correctly");

	if($variance > 0.5){
		$self->log->error("Variance is too high, something fishy. I should have \$$usd and $coin ${\$t->symbol()}" .
			" But instead I got: \$$usd_actual and ${\$self->_get_fund($t->symbol())}");
	}


	elsif($variance2 > 0.5){
		$self->log->error("Variance2 is too high, something fishy. I should have \$$usd and $coin ${\$t->symbol()}" .
			" But instead I got: \$$usd_actual and ${\$self->_get_fund($t->symbol())}");
	}
	else{
		$self->log->info("Everything looks good, I expected \$$usd and $coin ${\$t->symbol()} and I got ".
			"\$$usd_actual and ${\$self->_get_fund($t->symbol())}");
	}

}

sub _check_sell_amount
{
	my ($self,$price,$amount,$amount_usd) = @_;
	my $usd = ($price*$amount) + $amount_usd;
	my $variance = abs 100-($usd*100/$self->_get_fund('usd') );
	$self->log->info("Checking if sell order was processed correctly");
	if($variance > 0.5){
		$self->log->error("Variance is too high, something fishy. I should have gotten \$$usd" .
			" But instead I got: \$${\$self->_get_fund('usd')}");
#send email?
	}
	else{
		$self->log->info("Everything looks good, I expected \$$usd and I got \$${\$self->_get_fund('usd')}");
	}

}

sub _check_after_cancel
{
	my ($self, $t, $price, $amount, $amount_usd, $action) = @_;
	my $sym = $t->symbol();
	my $coin_before = $self->_get_fund($sym);

	$self->log->warn("Checking funds in account after canceling.");

	sleep 5; #sleep, then get actuals in account
		$self->_get_funds();

	if($action eq "sell"){
		$self->log->info("I had $coin_before $sym. Now I have ${\$self->_get_fund($sym)} $sym.");
		$self->log->info("I had \$$amount_usd before. Now I have \$${\$self->_get_fund('usd')}.");
		$t->amount($self->_get_fund($sym) );
	}
	elsif($action eq "buy"){
		$self->log->info("I had \$$amount_usd before. Now I have \$${\$self->_get_fund('usd')}.");
		$self->log->info("I had $coin_before $sym. Now I have ${\$self->_get_fund($sym)} $sym.");
		$t->amount($self->_get_fund($sym) );
	}


}

sub _get_buy_amount
{
	my ($self,$t,$price,$amount_usd) = @_;
	my $sym = $t->symbol();
	my $amount;

	if($sym eq 'btc'){
		if($self->_get_fund('btc') < 1){
			$amount = 1 - $self->_get_fund('btc');
		}
		else{
			$self->log->error("Why am I trying to buy more than one BTC?");
			$t->last_action('buy');
			return;
		}

		if(($amount * $price) > $amount_usd){
			$self->log->error("I can't afford one BTC right now. Lets recalculate.");
			$amount = $amount_usd / $price;
		}
	}
	else{
		my $ref = $self->_getTicker("btc_usd");
		if(not defined $ref or not $ref->{last} > 0){
			$self->log->error("Could not get ticker for btc_usd. Can't calculate.");
			return;
		}
		if($self->_get_fund("btc") < 1){ #always want to have enough for one btc
			$amount_usd = $amount_usd - ( (1 - $self->_get_fund("btc") ) * $ref->{last});
		}
		$amount = $amount_usd / $price;
	}


	return $amount;
}

sub _load_tickers
{
	my $self = shift();
	$self->log->info("Building tickers.");
	foreach my $sym (@{$self->symbols()}){
		my $t = BitTrader::Ticker->new('symbol' => $sym);
		$t->amount($self->_get_fund($sym));
		$self->_load_ticker_history($t) if($self->noload() != 1);
		$self->_set_ticker($t);
	}

	return;
}

sub _load_ticker_history
{
	my ($self,$t) = @_;
	my $qh;
	$self->log->info("Loading averages from DB for sym ${\$t->symbol()}.");
	$self->db_connect($self->_cfg->get_var("db_pass") );
	$qh = $self->prepare( "select price from btce_track where ts > CURRENT_DATE - 30 and symbol = ? order by ts ASC");
	$qh->execute($t->symbol() );
	while( my $ref = $qh->fetchrow_arrayref() ){
		$t->set_price($ref->[0]);
		$self->log->debug("Current price: ${\$t->price} Averages: ${\$t->avg} ${\$t->avg_slow} ${\$t->avg_slower} ${\$t->avg_slowest}");
	}
	$self->log->info("Loaded ticker:\n${\$t->ticker_status()}");
	$self->db_disconnect();
	return;  
}

sub _get_funds
{
	my $self = shift();
	$self->log->info("Getting funds from btce.");
	my $ref = $self->_getInfo();
	if(not defined $ref){
		$self->log->error("Network error getting funds!");
		return;
	}
	if(not defined $ref->{return}->{funds}){
		$self->log->error("Could not get funds!");
		$self->log->error($ref->{error}) if $ref->{error};
		return;
	}
	$ref = $ref->{return}->{funds};
	$self->_funds($ref);
}
__PACKAGE__->meta->make_immutable;

