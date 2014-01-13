#! /usr/bin/perl -w
use strict;
use Data::Dumper;
use DBI;
use Chart;
use Getopt::Long;
use Indicator::StochFast;
use Indicator::StochOsc;



my $last_action = "sold";
my $dbh;
my $btc;
my $usd = 2000;
my $avg;
#my $query = "select price,ts from btce_track where ts > CURRENT_DATE - 2 and symbol = ? order by ts ASC";
my $query = "select price,ts from btce_track where symbol = ? order by ts ASC";
my $qh;
my $last;
my $ts;
my $sym;
my $dochart;
my @chart;
my $indicator = Indicator::StochFast->new();

sub mysql_connect
{
  my $host = "127.0.0.1";
  my $database = "btce";
  my $user = "btce";
  my $pw = "123456";
  my $dsn = "dbi:mysql:$database:$host";
  return  DBI->connect($dsn, $user, $pw) or die "Unable to connect: $DBI::errstr\n";
}

sub ewa
{
  my ($current, $last, $alpha) = @_;
  $last = $current if not defined $last;
  my $ewa = (1 - $alpha) * $last + $alpha * $current;
  return sprintf("%.2f",$ewa);
}


GetOptions (
        "sym=s" => \$sym,
        "chart!" => \$dochart,
) or die("Wrong args!\n" );

$dbh = mysql_connect();
$qh = $dbh->prepare($query);
$qh->execute($sym);



while(my $ref = $qh->fetchrow_hashref() ){
  $last = $ref->{price};
  $avg = ewa($last,$avg,1/8);
  $ts = $ref->{ts};
  $indicator->set_price($last);
  next unless $indicator->k();
  
  if($last_action eq 'buy' and $indicator->should_sell() ){
	$last_action = 'sold';
        $usd = ($btc * $last) - (($btc*$last) *.002);
        $btc = 0;

        print "$ts $last $avg Selling: I have $usd usd and $btc btc\n";
        push(@chart, "$ts," . sprintf("%.2f",$last) . ",$avg," . $indicator->k . "," . $indicator->d . ",80" );
#        push(@chart, "$ts," . sprintf("%.2f",$last) . ",$avg," . $indicator->rsi );
	
  }
  elsif($last_action eq 'sold' and $indicator->should_buy() ){
	$last_action = 'buy';
        $btc = ($usd / $last) - (($usd/$last)*.002);
        $usd = 0;

        print "$ts $last $avg Buying: I have $usd usd and $btc btc\n";
        push(@chart, "$ts," . sprintf("%.2f",$last) . ",$avg," . $indicator->k . "," . $indicator->d . ",99" );
#        push(@chart, "$ts," . sprintf("%.2f",$last) . ",$avg," . $indicator->rsi );
  }
  else{
        push(@chart, "$ts," . sprintf("%.2f",$last) . ",$avg," . $indicator->k . "," . $indicator->d  . ",0");
#        push(@chart, "$ts," . sprintf("%.2f",$last) . ",$avg," .  $indicator->rsi );

  }


}

if($dochart){
	my $plotly = Chart->new(chart => \@chart);
	$plotly->convert();

}
