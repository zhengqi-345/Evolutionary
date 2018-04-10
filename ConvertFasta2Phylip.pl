#!/usr/bin/perl
#===============================================================================
#         FILE: ConvertFasta2Phylip.pl
#
#        USAGE: perl ConvertFasta2Phylip.pl [ -i input file name ] 
#							 [ -o output file name ]
#						     [ ... ]
#
#       AUTHOR: Zheng Qi (zhengq)
#        EMAIL: zhengq@umn.edu
# ORGANIZATION: University of Minnesota, Twin Cities
#      CREATED: 02/09/2018 01:20:49 PM
#      VERSION: 1.0
#===============================================================================
BEGIN{unshift @INC, "/home/katagirf/zhengq/Desktop/Soft/Perl_Module/"};

use strict;
use warnings;
use POSIX qw(strftime);
use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');
use Qi;

if($opt_i && $opt_o){

	print "   Input: $opt_i\n  Output: $opt_o\n\n";
	my $start_time = time;
	print strftime("   Start: %Y-%m-%d %H:%M:%S\n",localtime(time));

	open OUT, ">$opt_o" or die "Can not open the file:$!";
	my %hash = Qi::cons_database($opt_i);

    my @keys = keys %hash;

    my $key_length = 0;

    my $seq_length = 0;

    foreach my $key (@keys){
        chomp $key;
        if( $key_length < length($key)){
            $key_length = length($key);
        }

        my $tmp = length($hash{$key});
        if($seq_length == 0){
            $seq_length = $tmp;
        }else{
            if($seq_length != $tmp){
                warn "different sequence length";
            }else{
                next;
            }
        }

    }
    $key_length += 3;

    my $count = @keys;
    print OUT "$count $seq_length\n";
    foreach my $key (@keys){
        print OUT sprintf("%-*s",$key_length,$key);
        print OUT $hash{$key},"\n";
    }

	my $duration_time = time-$start_time;
	print strftime("     End: %Y-%m-%d %H:%M:%S\n",localtime(time));
	print "   Total: $duration_time s\.\n";

}else{
	&usage;
}

sub usage{
	die(
	qq!
   Usage: perl ConvertFasta2Phylip.pl [ -i Input_file ] [ -o Output_file ] 
  Author: Qi Zheng, zhengq\@umn.edu
 Version: v1.0
 Command: -i Input file name(Required)
 			 -o Output file name(Required)
Function: Template for Perl
	\n!
	)
}


