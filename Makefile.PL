use inc::Module::Install;
name 'Net-Qiita';
all_from 'lib/Net/Qiita.pm';

requires 'HTTP::Request';
requires 'JSON';
requires 'LWP::UserAgent';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
test_requires 'Test::Fatal';
auto_set_repository;
auto_include;
WriteAll;
