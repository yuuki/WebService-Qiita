use lib lib => 't/lib' => glob 'modules/*/lib';
use Net::Qiita::Test;
use Net::Qiita;

use Test::More;
use Test::Fatal;
use Test::Mock::LWP::Conditional;

subtest 'delegade' => sub {
    my $ROOT_URL = Net::Qiita::Client::Base::ROOT_URL;
    my $response = HTTP::Response->new(200);
    Test::Mock::LWP::Conditional->stub_request(
        "$ROOT_URL/user_items"  => $response,
        "$ROOT_URL/user_stocks" => $response,
        "$ROOT_URL/user"        => $response,
    );

    my $items = Net::Qiita->user_items;
    ok $items;
    $items = Net::Qiita->user_stocks;
    ok $items;
    $items = Net::Qiita->user;
    ok $items;
};


done_testing;
