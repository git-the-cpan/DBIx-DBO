use strict;
use warnings;
use DBD::SQLite 1.27;

package # hide from PAUSE
    DBIx::DBO::DBD::SQLite::Handle;
use DBIx::DBO::Common;

sub _get_table_schema {
    my $me = shift;
    my $schema = my $q_schema = shift;
    my $table = my $q_table = shift;
    ouch 'No table name supplied' unless defined $table and length $table;

    $q_schema =~ s/([\\_%])/\\$1/g if defined $q_schema;
    $q_table =~ s/([\\_%])/\\$1/g;

    # Try just these types
    my $info = $me->rdbh->table_info(undef, $q_schema, $q_table,
        'TABLE,VIEW,GLOBAL TEMPORARY,LOCAL TEMPORARY,SYSTEM TABLE', {Escape => '\\'})->fetchall_arrayref;
    ouch 'Invalid table: '.$me->_qi($table) unless $info and @$info == 1 and $info->[0][2] eq $table;
    return $info->[0][1];
}

package # hide from PAUSE
    DBIx::DBO::DBD::SQLite::Query;
use DBIx::DBO::Common;

sub fetch {
    my $me = shift;
    my $row = $me->SUPER::fetch;
    unless (defined $row or $me->{sth}->err) {
        $me->{Row_Count} = $me->{sth}->rows;
    }
    return $row;
}

sub rows {
    my $me = shift;
    $me->sql; # Ensure the Row_Count is cleared if needed
    defined $me->{Row_Count} ? $me->{Row_Count} : -1;
}

1;
