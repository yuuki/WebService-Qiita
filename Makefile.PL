use inc::Module::Install;
name 'WebService-Qiita';
author 'Yuuki Tsubouchi <yuki.tsubo@gmail.com>';
all_from 'lib/WebService/Qiita.pm';

requires 'Class::Accessor::Lite';
requires 'HTTP::Request';
requires 'JSON';
requires 'LWP::UserAgent';
requires 'parent';  # for ver less than 5.10
requires 'URI';

# for script
requires Encode;
requires 'Getopt::Long';
requires 'Path::Class';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
test_requires 'Test::Fatal';
test_requires 'Test::Mock::Guard';
test_requires 'Test::Mock::LWP::Conditional';

test_requires 'Exporter::Lite';
test_requires 'HTTP::Response';
test_requires 'Path::Class';

install_script 'script/qiita';
auto_include;
auto_set_repository;
WriteAll;
