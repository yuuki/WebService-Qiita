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
            user => {
                args => 'username',
                desc => 'Shows user info',
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
        my $me = $self->{client}->user;
        $self->dump_user($me);
    }
    elsif ($command eq 'user') {
        my $url_name = shift @ARGV;
        my $user = $self->{client}->user($url_name);
        $self->dump_user($user);
    }
    elsif ($command eq 'search') {
        $self->dump_search(join ' ', @ARGV);
    }
    else {
        diag("no such command $command") and return 1;
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

sub dump_user {
    my ($self, $user) = @_;

    filter_utf8($user);

    print <<USER;
user:  $user->{name}
id:    $user->{url_name}
URL:   $user->{url}
Description:
$user->{description}
WEB site URL: $user->{website_url}
Organization: $user->{organization}
location:     $user->{location}
followers:       $user->{followers}
following_users: $user->{following_users}
items:           $user->{items}

Twitter:  $user->{twitter}
GitHub:   $user->{github}
Facebook: $user->{facebook}
Linkedin: $user->{linkedin}
USER
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
