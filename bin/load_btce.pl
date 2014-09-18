#! /usr/bin/env perl
use warnings;
use strict;
use POSIX qw(setsid);
use DBI;
use Finance::btce;
use Time::HiRes qw/time sleep/;


#monitor tickers on btc-e.com, 
#insert values into DB for later testing
#runs as daemon if @ARGV > 0
#creates one child perl symbol

my @pids;
my $cfg = BitTrader::Config->new();

#kill pids on term
$SIG{TERM} = sub{
	warn get_time() . "Killing child processes\n";
	kill 'TERM', @pids;
	warn get_time() . "Exiting\n";
	exit;
};



sub mysql_connect
{
	my $host = "127.0.0.1";
	my $database = "btce";
	my $user = "btce";
	my $pw = $cfg->get_var("db_pass");
	my $dsn = "dbi:Pg:database=$database;host=$host";
	return  DBI->connect_cached($dsn, $user, $pw) || die "Unable to connect: $DBI::errstr\n";
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
	open STDOUT, ">>$ENV{HOME}/load_btce.log" or die "Can't write to log $!";
	open STDERR, ">>$ENV{HOME}/load_btce.log" or die "Can't write to log $!";
}



sub insert2
{
	my ($sym, $btce) = @_;
	my $last;
	my $dbh;
	my $qh;
	my $ref;
	my $count = 0;
	my $sleep_time;
	my $next_wakeup = time() + 10;


	while(1){
		$dbh = mysql_connect();

		unless($dbh){
			warn get_time() . "Coudln't connect to DB\n";
			sleep 1;
			next;
		}
		$qh = $dbh->prepare_cached("INSERT INTO btce_track (price,symbol,rate) VALUES(?,?,?)");
		unless($qh){
			warn get_time() .  "Couldn't prepare query\n";
			sleep 1;
			next;
		}

		$ref = $btce->getTicker($sym . "_usd");
		if( not defined $ref or not defined $ref->{last} or not $ref->{last} > 0){
			warn get_time() . "Last not defined.\n";
			warn get_time() . "Last not > 0. Last is: $ref->{last}\n" if( defined $ref->{last});
			next;
		}

		$last = $ref->{last};
		print get_time() . "Inserting for $sym price: $last\n";

		$qh->execute($last,$sym,10) or print "Coudn't insert for $sym\n";
		if($count == 30){
			$count = 0;
			$qh->execute($last,$sym,300) or print "Coudn't insert for $sym and rate 300\n";
		}
		$count++;
		STDOUT->flush();

		$sleep_time = $next_wakeup - time();
		if($sleep_time <= 0){
			$next_wakeup = time() + 10;
			next;
		}
		sleep $sleep_time;
		$next_wakeup += 10;
	}

}

###########################################################################

daemonize() if @ARGV;

my @symbols = qw/btc ltc nmc nvc ppc/;
my $btce = Finance::btce->new({
	apikey => $cfg->get_var("apikey"),
	secret => $cfg->get_var("apisecret"),
});


while( my $sym = pop(@symbols)){
	my $pid = fork();
	die "Fork failed\n" if($pid == -1);

	if($pid == 0){ #in child
		$SIG{TERM} = sub { exit; };
		insert2($sym,$btce);
	}
	else{
		push(@pids, $pid);
	}

}

while( my $pid = pop(@pids)){
	waitpid($pid,0);	
}


