#! /usr/bin/env perl
use warnings;
use strict;
use POSIX qw(setsid);
use Log::Log4perl qw(:easy);
use Data::Dumper;
use lib "lib/";
use BitTrader::Account;



#Log::Log4perl->easy_init($ERROR);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);
my $log = get_logger();



sub daemonize 
{
  my @fh_unused = (\*STDIN, );
  print "Forking now.\n";

  defined(my $pid = fork) or die "Can't fork: $!";
  exit if $pid;
  setsid or die "Can't start a new session: $!";
  umask 0;
  close $_ or die $! for @fh_unused;
  open STDOUT, ">>$ENV{HOME}/btce/btce.log" or die "Can't write to log $!";
  open STDERR, ">>$ENV{HOME}/btce/btce.log" or die "Can't write to log $!";
}


daemonize() if @ARGV;
my $account = BitTrader::Account->new('symbols' => ['btc','ltc']);



while(1){
  $account->poll();
  STDOUT->flush();
  sleep 300;
}

#foreach my $t (@{$account->_tickers()}){
#	$log->info( "ticker:" . $t->ticker_status());
#
#	my $ref = $account->_getTicker($t->symbol() . "_usd");
#	$account->_sell($t,$ref);
#
#	$log->info( "ticker:" . $t->ticker_status());
#}
#
#print "\nsleeping\n";
#sleep 10;
#
#foreach my $t (@{$account->_tickers()}){
#	$log->info( "ticker:" . $t->ticker_status());
#
#	my $ref = $account->_getTicker($t->symbol() . "_usd");
#	$account->_buy($t,$ref);
#
#	$log->info( "ticker:" . $t->ticker_status());
#}

print "EDN\n";


#http://www.investopedia.com/terms/s/stochasticoscillator.asp
#https://plot.ly/perl/script-demos/basic-line-chart-example/
