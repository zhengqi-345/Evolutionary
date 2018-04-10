#!/usr/bin/perl
#===============================================================================
#         FILE: 20170731_infer_ancestor.pl
#
#        USAGE: perl 20170731_infer_ancestor.pl [ -i input file name ] 
#							 [ -o output file name ]
#						     [ ... ]
#
#       AUTHOR: Zheng Qi (zhengq)
#        EMAIL: zhengq@umn.edu
# ORGANIZATION: University of Minnesota, Twin Cities
#      CREATED: 07/31/2017 12:16:46 PM
#      VERSION: 1.0
#===============================================================================

use strict;
use warnings;
use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');


if($opt_i && $opt_o){
	open FILE,"<$opt_i" or die "Can not open the file:$!";
	open OUT, ">$opt_o" or die "Can not open the file:$!";
	my %hash;

	foreach my $each (<FILE>){
		chomp($each);
		if($each =~ /^[0-9]*\s*:/){
			next;
		}elsif($each =~ /^\s*$/){
			next;
		}elsif($each =~ /^\n/){
			next;
		}else{
			my @each = split(/:/,$each);
			$each[1] =~ s/\s//g;
			$each[0] =~ s/\([A-Za-z0-9]\) \([A-Za-z0-9]\)/$1_$2/g;
			$each[0] =~ m/^[0-9]*/g;
			my $id = $&;
			if(exists $hash{$each[0]}){
				$hash{$each[0]}{seq} = join("",$hash{$each[0]}{seq},$each[1]);
			}else{
				$hash{$each[0]}{id}  = $id;
				$hash{$each[0]}{seq} = $each[1];
			}
		}
	}
	foreach my $each (sort { $hash{$a}{id} <=> $hash{$b}{id}} keys %hash ){
		print OUT ">",$each,"\n";#$hash{$each}{id},"\n";
		for(my $i=0;$i <=length($hash{$each}{seq});$i+=80){
			print OUT substr($hash{$each}{seq},$i,80),"\n";
		}
	}
}else{

	die "Error: there is improper parameter, please check it! \n";

}


