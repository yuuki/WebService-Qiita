package Net::Qiita::Test;
use strict;
use warnings;
use utf8;

sub import {
    my $class = shift;
    my $call_pkg = caller(0);

    strict->import;
    warnings->import;
    utf8->import;

    eval qq{
        package $call_pkg;
        use base qw($class);
        use Test::More;
        use Test::Fatal;
    };
}

1;
