package BitTrader::Config;
use namespace::autoclean;
use Moose; 
use Config::Simple;

has 'cfg' => (
	is => 'ro',
	isa => 'Config::Simple',
	writer => '_set_cfg',
);

has '_file' => ( 
	is => 'ro',
	isa => 'Str', 
	default => "$ENV{HOME}/.bit_trader/config.cfg"
);

sub BUILD
{
	my $self = shift();
	die "Cfg file not found: ${\$self->_file()}\n" unless -f $self->_file();
	$self->_set_cfg(Config::Simple->new($self->_file()));
}

sub get_var
{
	my ($self, $var) = @_;
	my $txt = $self->cfg->param($var);
	die "Coudn't get data for var $var\n" unless $txt;
	return $txt;
}

__PACKAGE__->meta->make_immutable;
