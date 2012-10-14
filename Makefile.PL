use inc::Module::Install;
name 'Net-Qiita';
author 'Yuuki Tsubouchi <yuki.tsubo@gmail.com>';
all_from 'lib/Net/Qiita.pm';

requires 'Exporter::Lite';
requires 'HTTP::Request';
requires 'JSON';
requires 'LWP';
requires 'parent';  # for ver less than 5.10
requires 'URI';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
test_requires 'Test::Fatal';
test_requires 'Test::Mock::Guard';
test_requires 'Test::Mock::LWP::Conditional';

test_requires 'HTTP::Response';
test_requires 'Path::Class';

auto_set_repository;
auto_include;
WriteAll;
