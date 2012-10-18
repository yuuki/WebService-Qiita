# Net::Qiita

Net::Qiita is a simple Perl wrapper for the Qiita API v1.

Qiita API documentaion here.

http://qiita.com/docs


## SYNOPSIS
Net::Qiita interface is very similer to the publc Ruby wrapper (https://github.com/yaotti/qiita-rb).

```perl
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
```

## LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

y_uuki
