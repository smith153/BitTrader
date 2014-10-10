package BitTrader::Role::DB_Handle;

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
	my $pw = shift();
	my $host = "127.0.0.1";
	my $database = "btce";
	my $user = "btce";
	my $dsn = "dbi:Pg:database=$database:host=$host";
	my $dbh = DBI->connect($dsn, $user, $pw) || die "Unable to connect: $DBI::errstr\n";
	$self->_set_dbh($dbh);
}


1;

__END__

=head1 NAME
BitTrader::Role::DB_Handle
=head1 SYNOPSIS

	use BitTrader::Role::DB_Handle
	$self->db_connect("password");
	my $qh = $self->prepare("select count(*) from table");
	$self->db_disconnect();

=head1 DESCRIPTION

Moose role to include a database handle

=cut

