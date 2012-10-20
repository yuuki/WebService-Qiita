package WebService::Qiita::CLI;
use utf8;
use strict;
use warnings;

use Encode;
use Getopt::Compact::WithCmd;
use Path::Class;

use WebService::Qiita;
use WebService::Qiita::Client;

our $VERSION = $WebService::Qiita::VERSION;

sub new {
    my $class = shift;

    my $filename = "$ENV{HOME}/.webservice-qiita";
    my $lines = -f $filename ? [ Path::Class::file($filename)->slurp ] : [];
    chomp for (@$lines);

    bless {
        client        => undef,
        auth_filename => $filename,
        auth_file     => $lines,
        command       => {},
        opts          => {},
        argv          => [],
        is_version    => 0,
    }, $class;
}

sub parse_options {
    my $self = shift;

    push @ARGV, @_;

    my $go = Getopt::Compact::WithCmd->new(
        name    => 'qiita',
        version => $VERSION,
        global_struct => [
           [ [qw(v version)], 'Displays version', '!', \$self->{is_version} ],
        ],
        command_struct => {
            search => {
                options => [
                    [ [qw(stocked s)], 'from your stocked items', '!', undef],
                ],
                args => 'query',
                desc => 'Shows search results',
            },
            me => {
                desc => 'Shows your info',
            },
        },
    );

    # TODO
    # --no-auth
    # --relogin

    $self->{opts}    = $go->opts;
    $self->{command} = $go->command;
    $self->{argv}    = \@ARGV;

}

sub run {
    my $self = shift;

    if ($self->{is_version}) {
        $self->show_version and return 0;
    }

    $self->is_loggedin or $self->login;
    $self->setup_client;

    my $command = $self->{command} or diag('no specified subcommand') and return 1;
    if ($command eq 'me') {
        $self->dump_me;
    }
    elsif ($command eq 'search') {
        $self->dump_search(join ' ', @ARGV);
    }

    return 0;
}

sub show_version {
    my $self = shift;
    print <<VER;
WebService::Qiita::CLI
Version: $VERSION
VER
    return 1;
}

sub is_loggedin {
    my $self = shift;

    return 0 unless $self->{auth_file};
    my $lines = $self->{auth_file};
    $lines->[0] =~ /[0-9a-zA-Z_\-@]+/ and $lines->[1] =~ /[0-9a-z]+/;
}

sub login {
    my $self = shift;

    print 'username: ';
    my $url_name = <STDIN>;

    print 'password: ';
    my $password = <STDIN>;

    chomp $url_name;
    chomp $password;
    $self->setup_client($url_name, $password);

    open OUT, "> " . $self->{auth_filename};
    print OUT $self->{client}->url_name . "\n";
    print OUT $self->{client}->token . "\n";
    close OUT;
}

sub setup_client {
    my ($self, $url_name, $password) = @_;

    my $lines = $self->{auth_file};
    $self->{client} ||= WebService::Qiita::Client->new(+{
        url_name => $url_name || $lines->[0],
        password => $password || undef,
        token    => $lines->[1],
    });
}

sub filter_utf8 {
    my $hash = $_[0];
    for (keys %$hash) {
        $hash->{$_} = defined $hash->{$_} ? $hash->{$_} : '';
        if (utf8::is_utf8($hash->{$_})) {
            $hash->{$_} = Encode::encode_utf8($hash->{$_});
        }
    }
}

sub dump_me {
    my $self = shift;

    my $me = $self->{client}->user;
    filter_utf8($me);

    print <<ME;
name:  $me->{name}
id:    $me->{url_name}
URL:   $me->{url}
Description:
$me->{description}
WEB site URL: $me->{website_url}
Organization: $me->{organization}
location:     $me->{location}
followers:       $me->{followers}
following_users: $me->{following_users}
items:           $me->{items}

Twitter:  $me->{twitter}
GitHub:   $me->{github}
Facebook: $me->{facebook}
Linkedin: $me->{linkedin}
ME
    return 1;
}

sub dump_search {
    my ($self, $query) = @_;

    unless ($query) {
        print STDERR "No given query\n";
        return 1;
    }
    my $items = $self->{client}->search_items($query);
    filter_utf8($_) for (@$items);

    for my $item (@$items) {
        my $tags_str = $item->{tag} ? join ' ', @{ $item->{tags} } : '';

        print <<SEARCH;
Author:  $item->{user}->{name}
Title:   $item->{title}
Content:    $item->{body}

$item->{updated_at_inwords}
$tags_str
Stock count: $item->{stock_count}
SEARCH
    }
    return 1;
}

sub diag {
    my $msg = shift;
    print STDERR "$msg\n";
    return 1;
}

1;
__END__
