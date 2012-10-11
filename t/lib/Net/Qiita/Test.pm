package Net::Qiita::Test;
use strict;
use warnings;
use utf8;

sub import {
    my $class = shift;

    strict->import;
    warnings->import;
    utf8->import;
}

1;
