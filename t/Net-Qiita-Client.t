use lib lib => 't/lib' => glob 'modules/*/lib';
use Net::Qiita::Test;
use Net::Qiita::Client;

use Test::More;
use Test::Fatal;
use Test::Mock::LWP::Conditional;

use HTTP::Response;
use JSON;

subtest accessor => sub {
    my $client = Net::Qiita::Client->new({
        url_name => 'y_uuki_',
        password => 'mysecret',
        token    => 'authtoken',
    });

    is $client->url_name, 'y_uuki_';
    is $client->password, 'mysecret';
    is $client->token,    'authtoken';
    isa_ok $client, 'Net::Qiita::Client::Base';
};

subtest token => sub {
    my $response = HTTP::Response->new(200);
    my $json = JSON::encode_json(+{url_name => 'y_uuki_', token => 'yoursecrettoken'});
    $response->content($json);
    Test::Mock::LWP::Conditional->stub_request(
        Net::Qiita::Client::Base::ROOT_URL . "/api/v1/auth" => $response,
    );

    my $client = Net::Qiita::Client->new({
        url_name => 'y_uuki_',
        password => 'mysecret',
    });

    is $client->url_name, 'y_uuki_';
    is $client->password, 'mysecret';
    is $client->token,    'yoursecrettoken';
};


done_testing;
