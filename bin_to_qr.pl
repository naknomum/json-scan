#!/usr/bin/perl

use JSON;
use Data::Dumper;


my $in = join('',<>);

use GD::Barcode::QRcode;
binmode(STDOUT);
print GD::Barcode::QRcode->new($in, { Ecc => 'M', Version => 10, ModuleSize => 6 })->plot->png;


