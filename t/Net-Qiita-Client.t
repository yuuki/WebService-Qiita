use lib lib => 't/lib' => glob 'modules/*/lib';
use Net::Qiita::Test;

use Net::Qiita::Client;

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

subtest delegade => sub {
};

done_testing;
