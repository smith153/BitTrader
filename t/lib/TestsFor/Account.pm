package TestsFor::BitTrader::Account;
use Test::Most;
use Test::MockObject::Extends;
use Finance::btce;
use base 'TestsFor';

my $btce;

sub startup : Test(startup)
{
  my $test = shift();
  $test->SUPER::startup;
  my $class = ref $test;
  $class->mk_classdata('default_account');
  Log::Log4perl->easy_init();

}


sub setup : Test(setup)
{
  my $test = shift();
  $test->SUPER::setup();

  $btce = Finance::btce->new({ apikey => 'fake', secret => 'fake',});
  mock_btce();

  $test->default_account( $test->class_to_test->new(
        'symbols' => ['btc', 'ltc'],
        'noload' => 1,
	'_btce' => $btce,
        )
  );


} 


sub constructor : Test(3) 
{ 

  my $test = shift();
  my $class = $test->class_to_test();
  can_ok $class, 'new';
  throws_ok {$class->new()} qr/Attribute.*required/, "Creating a $class without attributes should fail.";
  isa_ok $test->default_account, $class;
}

sub attributes : Test(7)
{
  my $test = shift();
  my $class = $test->class_to_test();
  can_ok $class, "symbols";
  can_ok $class, "_funds";
  can_ok $class, "noload";
  can_ok $class, "_tickers";
  can_ok $class, "_btce";
  can_ok $class, "dbh";
  can_ok $class, "_cfg";
}

sub my_methods : Test(11)
{
  my $test = shift();
  my $class = $test->class_to_test();
  can_ok $class, 'poll';
  can_ok $class, '_get_funds';
  can_ok $class, '_buy';
  can_ok $class, '_sell';
  can_ok $class, '_wait_on_market';
  can_ok $class, '_check_buy_amount';
  can_ok $class, '_check_sell_amount';
  can_ok $class, '_check_after_cancel';
  can_ok $class, '_get_buy_amount';
  can_ok $class, '_load_tickers';
  can_ok $class, '_load_ticker_history';

}










sub mock_btce
{



$btce = Test::MockObject::Extends->new($btce);

$btce->set_always(getTicker => {
          'vol_cur' => '16320.89588',
          'vol' => '17038475.28297',
          'avg' => '30.301485',
          'last' => 30,
          'sell' => 30,
          'buy' => '30',
          'high' => '30',
          'server_time' => 1385845491,
          'low' => '25',
          'updated' => 1385845490
  });
$btce->set_always(getInfo => {
          'success' => 1,
          'return' => {
                        'rights' => {
                                      'info' => 1,
                                      'withdraw' => 0,
                                      'trade' => 0
                                    },
                        'funds' => {
                                     'nvc' => 0,
                                     'nmc' => 0,
                                     'btc' => '0.53694401',
                                     'xpm' => 0,
                                     'usd' => '0.35863074',
                                     'ftc' => 0,
                                     'ltc' => 30,
                                     'trc' => 0,
                                     'rur' => 0,
                                     'ppc' => 0,
                                     'eur' => 0
                                   },
                        'server_time' => 1385845686,
                        'open_orders' => 1,
                        'transaction_count' => 108
                      }
  });
$btce->set_always(trade => {
          'success' => 1,
          'return' => {
                        'funds' => {
                                     'nvc' => 0,
                                     'nmc' => 0,
                                     'btc' => '1.01803021',
                                     'xpm' => 0,
                                     'usd' => '0.30042416',
                                     'ftc' => 0,
                                     'ltc' => '6.98292',
                                     'trc' => 0,
                                     'rur' => 0,
                                     'ppc' => 0,
                                     'eur' => 0
                                   },
                        'remains' => '1.1',
                        'order_id' => 79217481,
                        'received' => 0
                      }
  });
$btce->set_always(cancelOrder => {
          'success' => 1,
          'return' => {
                        'funds' => {
                                     'nvc' => 0,
                                     'nmc' => 0,
                                     'btc' => '1.01803021',
                                     'xpm' => 0,
                                     'usd' => '0.30042416',
                                     'ftc' => 0,
                                     'ltc' => '8.08292',
                                     'trc' => 0,
                                     'rur' => 0,
                                     'ppc' => 0,
                                     'eur' => 0
                                   },
                        'order_id' => 79214911
                      }
  });
$btce->set_always(activeOrders => {
          'success' => 1,
          'return' => {
                        '72807751' => {
                                        'rate' => '30',
                                        'timestamp_created' => 1385776149,
                                        'amount' => '73.966',
                                        'pair' => 'ltc_usd',
                                        'status' => 0,
                                        'type' => 'buy'
                                      }
                      }
  });



}
1;
