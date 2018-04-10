#!/usr/bin/perl
#===============================================================================
#         FILE: EvolView_annotation_20180126.pl
#
#        USAGE: perl EvolView_annotation_20180126.pl [ -i input file name ] 
#							 [ -o output file name ]
#						     [ ... ]
#
#       AUTHOR: Zheng Qi (zhengq)
#        EMAIL: zhengq@umn.edu
# ORGANIZATION: University of Minnesota, Twin Cities
#      CREATED: 01/26/2018 02:17:58 PM
#      VERSION: 1.0
#===============================================================================
BEGIN{unshift @INC, "/home/katagirf/zhengq/Desktop/Soft/Perl_Module/"};

use strict;
use warnings;
use POSIX qw(strftime);
use Getopt::Std;
use vars qw($opt_i $opt_o $opt_m $opt_s);
getopts('i:o:m:s:');
use Qi;

if($opt_i && $opt_o && $opt_m && $opt_s){

	print "   Input: $opt_i\n  Output: $opt_o\n\n";
	my $start_time = time;
	print strftime("   Start: %Y-%m-%d %H:%M:%S\n",localtime(time));

#    open COLOR, "/home/katagirf/zhengq/Desktop/Soft/20170418_Color_and_Species.txt" or die "Can not open the file:$!";
#    my %color;
#    foreach my $line (<COLOR>) {
#        chomp($line);
#        my @line = split(/\t/,$line);
#        if(exists $color{$line[0]}){
#            warn "There is duplicated specie ID";
#        }else{
#            $color{$line[0]}{specie} = $line[1];
#            $color{$line[0]}{order}  = $line[2];
#            $color{$line[0]}{color}  = $line[3];
#        }
#    }

    open MOTIF, "/home/katagirf/zhengq/Desktop/Soft/140_color.txt" or die "Can not open the file:$!";
    my @motif = <MOTIF>;

	open FILE,"<$opt_i" or die "Can not open the file:$!";
	
    my %hash;
    my %motif;

    my $count=0;
	foreach my $each (<FILE>){
		chomp($each);
        if($each =~ /^#/){
            next;
        }elsif($each =~ /^\n/){
            next;
        }elsif($each =~ /^\(/){
            next;
        }else{
            $each =~ s/ {1,}/\t/g;
            my @each = split(/\t/,$each);

            if($each[17] >= $each[18]){
                next;
            }else{

                if($count < $each[5]){
                    $count = $each[5];
                }

                if($each[0] =~ /LRR_/){
                    if($each[0] !~ /$opt_s/){
                        next;
                    }else{
		                if(not exists $motif{$each[0]}){
		                    my $id = shift(@motif);
		                    chomp($id);
		                    my @id = split(/\t/,$id);
		                    $motif{$each[0]}{color} = $id[1];
		                    if($each[0] =~ /$opt_m/i){
		                        $motif{$each[0]}{shape} = "RE";
		                    }else{
		                        $motif{$each[0]}{shape} = "RE";
                                #$motif{$each[0]}{shape} = "EL";
		                    }
		                }
		
		                if(exists $hash{$each[3]}){
		                    $hash{$each[3]} = join("\t",$hash{$each[3]},join("|",$motif{$each[0]}{shape},$each[17],$each[18],$motif{$each[0]}{color},$each[0]));
		                }else{
		                    $hash{$each[3]} = join("\t",$each[3],$each[5],join("|",$motif{$each[0]}{shape},$each[17],$each[18],$motif{$each[0]}{color},$each[0]));
		                }
                    }
                }

                if(not exists $motif{$each[0]}){
                    my $id = shift(@motif);
                    chomp($id);
                    my @id = split(/\t/,$id);
                    $motif{$each[0]}{color} = $id[0];
                    if($each[0] =~ /$opt_m/i){
                        $motif{$each[0]}{shape} = "RE";
                    }else{
                        $motif{$each[0]}{shape} = "EL";
                    }
                }

                if(exists $hash{$each[3]}){
                    $hash{$each[3]} = join("\t",$hash{$each[3]},join("|",$motif{$each[0]}{shape},$each[17],$each[18],$motif{$each[0]}{color},$each[0]));
                }else{
                    $hash{$each[3]} = join("\t",$each[3],$each[5],join("|",$motif{$each[0]}{shape},$each[17],$each[18],$motif{$each[0]}{color},$each[0]));
                }
            }
        }	
	}
    
    open DOMAIN, ">$opt_o" or die "Can not open the file:$!";
    my $n = ($count/500)+1;
    my $scale=1;
    for(my $i =1;$i<$n;$i++){
        $scale = join("\t",$scale,$i*500)
    }

    print DOMAIN "DATASET_DOMAINS","\n";
    print DOMAIN "SEPARATOR"," ","TAB","\n";
    print DOMAIN "DATASET_LABEL","\t","domain annotation\n";
    print DOMAIN "LEGEND_TITLE","\t","Motif","\n";
    print DOMAIN "LEGEND_SHAPES","\t","RE","\t","EL","\n";
    print DOMAIN "LEGEND_COLORS","\t",$motif{$opt_m}{color},"\t","#ffffff","\n";
    print DOMAIN "DATASET_SCALE","\t",$scale,"\n";
    print DOMAIN "SHOW_INTERNAL","\t","0\n";
    print DOMAIN "MARGIN","\t","0\n";
    print DOMAIN "HEIGHT_FACTOR","\t","1\n";
    print DOMAIN "BAR_SHIFT","\t","0\n";
#    print DOMAIN "SHOW_DOMAIN_LABELS","\t","1\n";
    print DOMAIN "SHOW_DOMAIN_LABELS","\t","0\n";
    print DOMAIN "LABELS_ON_TOP","\t","0\n";
    print DOMAIN "BACKBONE_COLOR","\t","#000000\n";
    print DOMAIN "DATA\n";

    foreach my $output (sort{$a cmp $b} keys %hash){
        print DOMAIN $hash{$output},"\n";

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
   Usage: perl EvolView_annotation_20180126.pl [ -i Input_file ] [ -o Output_file ] [-m Motif_name] [ -s Second motif ]
  Author: Qi Zheng, zhengq\@umn.edu
 Version: v1.0
 Command: -i Input file name(Required)
 			 -o Output file name(Required)
             -m Motif name(Required)
             -s Second motif name(Required)
Function: Template for Perl
	\n!
	)
}


