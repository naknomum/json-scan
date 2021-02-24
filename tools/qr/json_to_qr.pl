#!/usr/bin/perl


#will convert JSON hash on STDIN into QR code on STDOUT

#note: if a key of '_file' is encountered, value should be filepath, will return hash with keys "data" and "type".
###### this is very alpha feature, use at own risk!  TODO


##### others:
##### http://search.cpan.org/~mstrat/Barcode-DataMatrix-0.04/lib/Barcode/DataMatrix.pm

use JSON;
use Data::Dumper;
#use Encode::BOCU1;
use Compress::LZF;
use MIME::Base64;
use GD::Image;

$version = "0.1";

#considered an optional compressed format but never saved much and seemed overcomplicated.  dropped!  (for now?)
$compress = 0;

my $in = join('',<>);
my $data = from_json($in);

&convert_binary($data);

$data->{JSONscan} = $version;

my $jsonout = to_json($data, {utf8=>1, pretty=>0});
warn "$jsonout\n";

if ($compress) {
	#Encode::from_to($jsonout, 'utf8', 'bocu1');
	$jsonout = compress "QRJSONC$version$jsonout";
}

use GD::Barcode::QRcode;
my $qr;
TRY: foreach my $version (1, 2, 3, 4, 10, 25) {
	foreach my $correction ('H', 'Q', 'M') {
		eval { $qr = GD::Barcode::QRcode->new($jsonout, { Ecc => $correction, Version => $version, ModuleSize => 6 }); };
		if ($qr) {
			warn length($jsonout)*8 . " bits fit using: v$version $correction\n";
			last TRY;
		}
	}
}

die "could not fit json data, sorry!\n" unless $qr;

binmode(STDOUT);
print $qr->plot->png;



sub convert_binary {
	my $h = shift;
	if (ref $h eq 'HASH') {
		foreach my $key (keys %$h) {
			if ($key eq '_file') {
				&readfile($h->{$key}, $h);
				delete($h->{_file});
			} elsif (ref $h->{$key} eq 'HASH' || ref $h->{$key} eq 'ARRAY') {
				&convert_binary($h->{$key});
			}
		}
	}
}


sub readfile {
	my ($file, $h) = @_;
	open(F,$file) || return;
	my $contents = join('',<F>);
	close(F);

	$h->{data} = encode_base64($contents);
	$h->{type} = 'image/png' unless $h->{type};  #TODO real mime, duh!
}

