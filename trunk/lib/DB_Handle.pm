
package DB_Handle
{       
  use namespace::autoclean;
  use Moose::Role;
  use DBI;

  has 'dbh' => (
	is => 'ro',
	isa => 'DBI::db',
	writer => '_set_dbh',
	handles => {
		prepare => 'prepare',
		db_disconnect => 'disconnect',
		do => 'do',
		},
	);

  sub db_connect
  {
	my $self = shift();
	my $host = "127.0.0.1";
	my $database = "btce";
	my $user = "btce";
	my $pw = "xxxx";
	my $dsn = "dbi:mysql:$database:$host";
	my $dbh = DBI->connect($dsn, $user, $pw) or die "Unable to connect: $DBI::errstr\n";
	$self->_set_dbh($dbh);
  }
}

1;

