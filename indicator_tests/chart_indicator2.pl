#! /usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
use DBI;
use Chart;
use Getopt::Long;
#use Indicator::StochFast;
#use Indicator::StochOsc;
use BitTrader::Indicator::Ma;
use BitTrader::Config;
use Math::EWMA;

my $cfg = BitTrader::Config->new();

my $last_action = "sold";
my $dbh;
my $btc;
my $usd = 2000;
my $avg;

#my $query = "select price,ts from btce_track where ts > date_sub(current_date, INTERVAL 40 day) and symbol = ? order by ts ASC";
my $query =
"select price,ts from btce_track where symbol = ? and rate = 300  and ts >= CURRENT_TIMESTAMP - INTERVAL '9000 DAY' order by ts ASC";
my $qh;
my $last;
my $ts;
my $sym;
my $dochart;
my @chart;

#my $indicator = Indicator::StochOsc->new();
my $indicator = BitTrader::Indicator::Ma->new(
    avg => Math::EWMA->new(alpha => 2/(288*1)),
    avg_slow => Math::EWMA->new(alpha => 2/(288*5)),
    avg_slower => Math::EWMA->new(alpha => 2/(288*16)),
    avg_slowest => Math::EWMA->new(alpha => 2/(288*32)),
);

sub mysql_connect
{
    my $host     = "127.0.0.1";
    my $database = "btce";
    my $user     = "btce";
    my $pw       = $cfg->get_var("db_pass");
    my $dsn      = "dbi:Pg:database=$database;host=$host";
    return DBI->connect( $dsn, $user, $pw )
      || die "Unable to connect: $DBI::errstr\n";
}

sub ewa
{
    my ( $current, $last, $alpha ) = @_;
    $last = $current if not defined $last;
    my $ewa = ( 1 - $alpha ) * $last + $alpha * $current;
    return sprintf( "%.2f", $ewa );
}

GetOptions(
    "sym=s"  => \$sym,
    "chart!" => \$dochart,
) or die("Wrong args!\n");

$dbh = mysql_connect();
$qh  = $dbh->prepare($query);
$qh->execute($sym);

my $count = 0;

while ( my $ref = $qh->fetchrow_hashref() ) {
    $last = $ref->{price};
    $avg  = ewa( $last, $avg, 1 / 8 );
    $ts   = $ref->{ts};
    $indicator->set_price($last);
    $count++;

    if ( $last_action eq 'buy' and $indicator->should_sell() ) {
        $last_action = 'sold';
        $usd         = ( $btc * $last ) - ( ( $btc * $last ) * .002 );
        $btc         = 0;

        print $indicator->status;
        print "$ts $last $avg Selling: I have $usd usd and $btc btc\n";
        push( @chart,
                "$ts,"
              . sprintf( "%.2f", $last )
              . ",$avg,${\$indicator->avg->ewma},${\$indicator->avg_slow->ewma},${\$indicator->avg_slower->ewma},${\$indicator->avg_slowest->ewma},80"
        );

    } elsif ( $last_action eq 'sold' and $indicator->should_buy() ) {
        $last_action = 'buy';
        $btc         = ( $usd / $last ) - ( ( $usd / $last ) * .002 );
        $usd         = 0;
        print $indicator->status;
        print "$ts $last $avg Buying: I have $usd usd and $btc btc\n";

        push( @chart,
                "$ts,"
              . sprintf( "%.2f", $last )
              . ",$avg,${\$indicator->avg->ewma},${\$indicator->avg_slow->ewma},${\$indicator->avg_slower->ewma},${\$indicator->avg_slowest->ewma},99"
        );
    } else {

        push( @chart,
                "$ts,"
              . sprintf( "%.2f", $last )
              . ",$avg,${\$indicator->avg->ewma},${\$indicator->avg_slow->ewma},${\$indicator->avg_slower->ewma},${\$indicator->avg_slowest->ewma},0"
        );

    }

}

if ($dochart) {
    print "doing chart\n";
    my $plotly = Chart->new( chart => \@chart );
    $plotly->convert();

}
