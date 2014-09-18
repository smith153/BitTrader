#! /usr/bin/env perl
use warnings;
use strict;
use POSIX qw(setsid);
use DBI;
use Finance::btce;
use BitTrader::Config;

#monitor tickers on btc-e.com, 
#insert values into DB for later testing


my $cfg = BitTrader::Config->new();

sub mysql_connect
{
	my $host = "127.0.0.1";
	my $database = "btce";
	my $user = "btce";
	my $pw = $cfg->get_var("db_pass");
	my $dsn = "dbi:Pg:database=$database;host=$host";
	return  DBI->connect($dsn, $user, $pw) || die "Unable to connect: $DBI::errstr\n";
}

sub get_time
{
	my $t = localtime();
	return "[$t] ";
}

sub daemonize 
{
	my @fh_unused = (\*STDIN, );
	print "Forking now.\n";

	defined(my $pid = fork) or die "Can't fork: $!";
	exit if $pid;
	setsid or die "Can't start a new session: $!";
	umask 0;
	close $_ or die $! for @fh_unused;
	open STDOUT, ">>$ENV{HOME}/btce/load_btce.log" or die "Can't write to log $!";
	open STDERR, ">>$ENV{HOME}/btce/load_btce.log" or die "Can't write to log $!";
}


sub insert
{
	my ($sym, $btce,$rate) = @_;
	my $last;
	my $dbh = mysql_connect();
	my $ref = $btce->getTicker($sym . "_usd");

	if( not defined $ref or not defined $ref->{last} or not $ref->{last} > 0){
		warn get_time() . "Last not defined.\n";
		warn get_time() . "Last not > 0. Last is: $ref->{last}\n" if( defined $ref->{last});
		exit();
	}
	$last = $ref->{last};
	print get_time() . "Inserting for $sym price: $last\n";
	$dbh->do("INSERT INTO btce_track (price,symbol,rate) VALUES(?,?,?)",undef, $last,$sym,10) or print "Coudn't insert for $sym\n";
	if($rate != 10){
		$dbh->do("INSERT INTO btce_track (price,symbol,rate) VALUES(?,?,?)",undef, $last,$sym,300) or print "Coudn't insert for $sym\n";
	}
	$dbh->disconnect();
	exit();

}

###########################################################################

daemonize() if @ARGV;
$SIG{CHLD} = "IGNORE";

my $i = 0;
my $rate;
#my @symbols = qw/btc ltc nmc nvc ppc/;
my @symbols = qw/btc ltc/;
my $btce = Finance::btce->new({
	apikey => $cfg->get_var("apikey"),
	secret => $cfg->get_var("apisecret"),
});


while(1){
	if($i != 30){
		$rate = 10;
		$i++;
	}
	else{
		$rate = 310;
		$i = 0;
	}

	foreach my $sym (@symbols){
		my $pid = fork();
		die "fork failed" if $pid == -1;
		if($pid == 0){ #in child
			insert($sym,$btce,$rate);
		}
	}

	sleep 10;
	STDOUT->flush();
}


