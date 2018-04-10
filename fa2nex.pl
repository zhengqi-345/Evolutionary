#!/usr/bin/perl
#===============================================================================
#         FILE: fa2nex.pl
#
#        USAGE: perl fa2nex.pl [ -i input file name ] 
#							 [ -o output file name ]
#						     [ ... ]
#
#       AUTHOR: Zheng Qi (zhengq)
#        EMAIL: zhengq@umn.edu
# ORGANIZATION: University of Minnesota, Twin Cities
#      CREATED: 05/26/2017 09:48:21 AM
#      VERSION: 1.0
#===============================================================================

use strict;
use warnings;
use Getopt::Std;
use File::Basename;
use vars qw($opt_i $opt_o $opt_n);
getopts('i:o:n:');


if($opt_i && $opt_o && $opt_n){
	open FILE,"<$opt_i" or die "Can not open the file:$!";
	open OUT, ">$opt_o" or die "Can not open the file:$!";
	my %hash;
	$/=">";
	my @file = <FILE>;
	shift @file;
	my $ntax= @file;
	my $length=0;
	foreach my $each (@file){
		chomp($each);
		my @each = split(/\n/,$each);
		my $id = shift @each;
		my $sequence = join("",@each);
		if($length == 0 or $length == length($sequence)){
			$length= length($sequence);
		}else{
			die "Sequence length is incorrect";
		}
		if(exists $hash{$id}){
			die "There is duplicate genes in data";
		}else{
			$hash{$id} = $sequence;
		}
	}
	$/="\n";
	print OUT "#NEXUS\n";
	print OUT "BEGIN DATA;\n";
	print OUT "DIMENSIONS NTAX=",$ntax," NCHAR=",$length,";\n";
	print OUT "FORMAT DATATYPE=PROTEIN GAP=- MISSING=?",";\n";
	print OUT "MATRIX\n\n";
	foreach(sort { $a cmp $b } keys %hash){
		printf OUT ("%-40s",$_);
		print OUT $hash{$_},"\n";
	}
	print OUT ";\n";
	print OUT "END;","\n";
	print OUT "BEGIN mrbayes;\n";
	print OUT "\t\tset autoclose=yes nowarn=yes;","\n";
	print OUT "\t\tprset aamodelpr= fixed(blosum);","\n";
	print OUT "\t\tmcmc ngen=",$opt_n," stoprule=yes  stopval=0.01 file=",basename($opt_o),";\n";
	print OUT "\t\tsumt;\n\t\tsump;\n\t\tquit;\n";
	print OUT "END;";

}else{

	die "Error: there is improper parameter, please check it! \n";

}


