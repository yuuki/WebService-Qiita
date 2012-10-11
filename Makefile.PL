use inc::Module::Install;
name 'Net-Qiita';
all_from 'lib/Net/Qiita.pm';

requires 'Exporter::Lite';
requires 'HTTP::Request';
requires 'JSON';
requires 'LWP::UserAgent';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
test_requires 'Test::Fatal';
test_requiest 'Test::Mock::LWP::Conditional';
test_requiest 'Test::Mock::Guard';

auto_set_repository;
auto_include;
WriteAll;
