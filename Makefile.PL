use inc::Module::Install;
name 'Net-Qiita';
all_from 'lib/Net/Qiita.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
