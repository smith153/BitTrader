#! /usr/bin/perl -w
use strict;
use POSIX qw(setsid);
use Log::Log4perl qw(:easy);
use Data::Dumper;
use lib "lib/";
use Account;



Log::Log4perl->easy_init($INFO);
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
my $account = Account->new('symbols' => ['btc','ltc']);



while(1){
  $account->poll();
  STDOUT->flush();
  sleep 300;
}

