package WebService::Qiita::CLI;
use utf8;
use strict;
use warnings;

use Encode;
use Getopt::Long;
use Path::Class;

use WebService::Qiita::Client;

sub new {
    my $class = shift;

    my $filename = "$ENV{HOME}/.webservice-qiita";
    my $lines = -f $filename ? [ Path::Class::file($filename)->slurp ] : [];
    chomp for (@$lines);

    bless {
        argv          => [],
        client        => undef,
        auth_filename => $filename,
        auth_file     => $lines,
        command       => {},
    }, $class;
}

sub parse_options {
    my $self = shift;

    push @ARGV, @_;

    Getopt::Long::Configure("bundling");
    Getopt::Long::GetOptions(
        'h|help'    => sub { $self->{action} = 'show_help' },
        'v|version' => sub { $self->{action} = 'show_version' },
        'me=s',     => \$self->{command}->{me},
    );

    # TODO
    # --no-auth
    # --relogin

    $self->{argv} = \@ARGV;
}

sub run {
    my $self = shift;


    if (my $action = $self->{action}) {
        $self->$action() and return 1;
    }

    $self->is_loggedin or $self->login;
    $self->setup_client;

    for my $command (@{ $self->{argv} }) {
        if ($command eq 'me') {
            $self->dump_me and return 1;
        }
    }

}

sub show_help {
    my $self = shift;

    print <<HELP;
Usage: qiita [--version] [--help] <command> [<args>]

Options:
  -v,--version              Displays software version
  -h,--help                 Displays help

Commands:
  search                    Shows search results
  me                        Shows your info
HELP

    return 1;
}

sub is_loggedin {
    my $self = shift;

    return 0 unless $self->{auth_file};
    my $lines = $self->{auth_file};
    return ($lines->[0] =~ /[0-9a-zA-Z_\-@]+/ and $lines->[1] =~ /[0-9a-z]+/);
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

sub dump_me {
    my $self = shift;

    my $me = $self->{client}->user;
    for (keys %$me) {
        $me->{$_} = defined $me->{$_} ? $me->{$_} : '';
        if (utf8::is_utf8($me->{$_})) {
            $me->{$_} = Encode::encode_utf8($me->{$_});
        }
    }
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

1;
__END__
