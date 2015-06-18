use utf8;
package BitTrader::Schema::Result::BtceTrack;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

BitTrader::Schema::Result::BtceTrack

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<btce_track>

=cut

__PACKAGE__->table("btce_track");

=head1 ACCESSORS

=head2 price

  data_type: 'double precision'
  is_nullable: 0

=head2 symbol

  data_type: 'varchar'
  is_nullable: 0
  size: 6

=head2 ts

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 rate

  data_type: 'smallint'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "price",
  { data_type => "double precision", is_nullable => 0 },
  "symbol",
  { data_type => "varchar", is_nullable => 0, size => 6 },
  "ts",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "rate",
  { data_type => "smallint", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</symbol>

=item * L</rate>

=item * L</ts>

=back

=cut

__PACKAGE__->set_primary_key("symbol", "rate", "ts");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-06-18 00:23:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EuZ8SlStAHsDWORGPUnUNQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
