#!/usr/bin/perl

#quick n dirty way to convert binary blob on STDIN to a QR code on STDOUT (in theory?)

use JSON;
use Data::Dumper;


my $in = join('',<>);

use GD::Barcode::QRcode;
binmode(STDOUT);
print GD::Barcode::QRcode->new($in, { Ecc => 'M', Version => 10, ModuleSize => 6 })->plot->png;


