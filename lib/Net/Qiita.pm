package Net::Qiita;
use strict;
use warnings;
use utf8;
our $VERSION = '0.02';

use Carp qw(croak);

use Net::Qiita::Client;


sub new {
    my ($class, %options) = @_;

    Net::Qiita::Client->new(\%options);
}

# Delegade method to Net::Qiita::Client object
sub AUTOLOAD {
    my $func = our $AUTOLOAD;
       $func =~ s/.*://g;
    my (@args) = @_;

    {
        no strict 'refs';

        *{$AUTOLOAD} = sub {
            my $class  = shift;
            my $client = $class->new;
            defined $client->can($func) || croak "no such func $func";
            shift @args;
            $client->$func(@args);
        };
    }
    goto &$AUTOLOAD;
}

sub DESTROY {}

1;
__END__

=head1 NAME

Net::Qiita - Perl wrapper for the Qiita API

=head1 SYNOPSIS

  use Net::Qiita;

  my $user_items = Net::Qiita->user_items('y_uuki_');

  my $tag_items = Net::Qiita->tag_items('perl');

  my $item_uuid = '1234567890abcdefg';
  my $markdown_content = Net::Qiita->item(item_uuid);

  my $client = Net::Qiita->new(
    url_name => 'y_uuki_',
    password => 'mysecret',
  );
  # or
  $client = Net::Qiita->new(
    token => 'myauthtoken',
  );

  $user_items = $client->user_items;


=head1 DESCRIPTION

Net::Qiita is a wrapper for Qiita API.

=head1 AUTHOR

Yuuki Tsubouchi E<lt>yuki.tsubo@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
