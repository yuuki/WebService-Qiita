use lib lib => 't/lib' => glob 'modules/*/lib';
use Net::Qiita::Test qw(client api_endpoint);
use Net::Qiita;
use Net::Qiita::Client::Users;

use Test::More;
use Test::Fatal;
use Test::Mock::LWP::Conditional qw(stub_request);

use HTTP::Response;
use JSON qw(encode_json decode_json);
use Path::Class qw(file);

subtest user_items => sub {
    my $data = file('t/data/user_items')->slurp;
    my $response = HTTP::Response->new(200);
    $response->content($data);

    my $data_arrayref = decode_json($data);

    subtest instance_method => sub {
        Test::Mock::LWP::Conditional->stub_request(
            api_endpoint('/items') => $response,
        );
        my $client = client(token => 'auth');
        my $items = $client->user_items;

        is_deeply $items, $data_arrayref;

        Test::Mock::LWP::Conditional->reset_all;
    };

    subtest class_method => sub {
        Test::Mock::LWP::Conditional->stub_request(
            api_endpoint('/users/y_uuki_/items') => $response,
        );
        my $items = Net::Qiita->user_items('y_uuki_');

        is_deeply $items, $data_arrayref;

        Test::Mock::LWP::Conditional->reset_all;
    };
};

subtest user_stocks => sub {
    my $data = file('t/data/user_stocks')->slurp;
    my $response = HTTP::Response->new(200);
    $response->content($data);

    my $data_arrayref = decode_json($data);

    subtest instance_method => sub {
        Test::Mock::LWP::Conditional->stub_request(
            api_endpoint('/stocks') => $response,
        );
        my $client = client(token => 'auth');
        my $items = $client->user_stocks;

        is_deeply $items, $data_arrayref;

        Test::Mock::LWP::Conditional->reset_all;
    };

    subtest class_method => sub {
        Test::Mock::LWP::Conditional->stub_request(
            api_endpoint('/users/y_uuki_/stocks') => $response,
        );
        my $items = Net::Qiita->user_stocks('y_uuki_');

        is_deeply $items, $data_arrayref;

        Test::Mock::LWP::Conditional->reset_all;
    };
};

subtest user => sub {
    my $data = file('t/data/user')->slurp;
    my $response = HTTP::Response->new(200);
    $response->content($data);

    my $data_arrayref = decode_json($data);

    Test::Mock::LWP::Conditional->stub_request(
        api_endpoint('/users/y_uuki_') => $response,
    );

    subtest instance_method => sub {
        my $client = client(token => 'auth');
        my $items = $client->user('y_uuki_');

        is_deeply $items, $data_arrayref;
    };

    subtest class_method => sub {
        Test::Mock::LWP::Conditional->stub_request(
            api_endpoint('/users/y_uuki_') => $response,
        );
        my $items = Net::Qiita->user('y_uuki_');

        is_deeply $items, $data_arrayref;
    };

    Test::Mock::LWP::Conditional->reset_all;
};

done_testing;
__END__
