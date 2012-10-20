package WebService::Qiita;
use strict;
use warnings;
use utf8;
our $VERSION = '0.04';

use Carp qw(croak);

use WebService::Qiita::Client;


sub new {
    my ($class, %options) = @_;

    WebService::Qiita::Client->new(\%options);
}

# Delegade method to WebService::Qiita::Client object
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

WebService::Qiita - Perl wrapper for the Qiita API

=head1 SYNOPSIS

  use WebService::Qiita;

  my $user_items = WebService::Qiita->user_items('y_uuki_');

  my $tag_items = WebService::Qiita->tag_items('perl');

  my $item_uuid = '1234567890abcdefg';
  my $markdown_content = WebService::Qiita->item(item_uuid);

  my $client = WebService::Qiita->new(
    url_name => 'y_uuki_',
    password => 'mysecret',
  );
  # or
  $client = WebService::Qiita->new(
    token => 'myauthtoken',
  );

  $user_items = $client->user_items;


=head1 DESCRIPTION

WebService::Qiita is a wrapper for Qiita API.

=head1 AUTHOR

Yuuki Tsubouchi E<lt>yuki.tsubo@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
