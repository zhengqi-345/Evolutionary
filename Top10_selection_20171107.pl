#!/usr/bin/perl
#===============================================================================
#         FILE: Top10_selection_20171107.pl
#
#        USAGE: perl Top10_selection_20171107.pl [ -i input file name ] 
#							 [ -o output file name ]
#						     [ ... ]
#
#       AUTHOR: Zheng Qi (zhengq)
#        EMAIL: zhengq@umn.edu
# ORGANIZATION: University of Minnesota, Twin Cities
#      CREATED: 11/07/2017 09:22:02 AM
#      VERSION: 1.0
#===============================================================================
BEGIN{unshift @INC, "/home/katagirf/zhengq/Desktop/Soft/Perl_Module"};
use strict;
use warnings;
use POSIX qw(strftime);
use Getopt::Std;
use vars qw($opt_i $opt_o $opt_d $opt_n);
getopts('i:o:d:n:');
use Qi;


if($opt_i && $opt_o && $opt_d){

	print "   Input: $opt_i\n  Output: $opt_o\n\n";
	my $start_time = time;
	print strftime("   Start: %Y-%m-%d %H:%M:%S\n",localtime(time));

	open FILE,"<$opt_i" or die "Can not open the file:$!";
	my %hash;

    if( ! $opt_n){
        $opt_n=3;
    }
	foreach my $each (<FILE>){
		chomp($each);
		my @each = split(/\t/,$each);
        my @species = split(/_/,$each[1]);
        if(exists $hash{$each[0]}{$each[1]}){
            $hash{$each[0]}{$each[1]} += $each[11];
        }else{
            $hash{$each[0]}{$each[1]} = $each[11];
        }
		
	}
    my %record;
    my %database = Qi::cons_database("$opt_d");
    foreach my $query (keys %hash){
        my %result;
        my %tidy;
        foreach my $subj (keys %{$hash{$query}}){
            my @species = split(/_/,$subj);
            my $bitscore = $hash{$query}{$subj};
            $tidy{$species[0]}{$bitscore}{$subj}= $bitscore;
        }
        foreach my $tidy_species (sort {$a cmp $b} keys %tidy){
            my @bitscore = keys %{ $tidy{$tidy_species} };
            my @bitscore_sort = sort {$b <=> $a } @bitscore;
            undef @bitscore;

            my $count = @bitscore_sort;
            if($count >= $opt_n){
                $count= $opt_n;            
            }
            for (my $i=0;$i <$count;$i++){
                foreach my $tidy_subj (sort{ $a cmp $b }keys %{$tidy{$tidy_species}{$bitscore_sort[$i]}}){
                    $result{$tidy_subj}{bitscore} = $bitscore_sort[$i];
                    print $query,"\t",$tidy_subj,"\t",$bitscore_sort[$i],"\n";
                    my @each_line = split(/_/,$tidy_subj);
                    if(exists $record{$query}{$each_line[0]}){
                        $record{$query}{$each_line[0]} += 1;
                    }else{
                        $record{$query}{$each_line[0]}  = 0;
                    }
                }
            }
        }
        my $out = join("_",$query,$opt_o);
	    open OUT, ">$out" or die "Can not open the file:$!";
        foreach my $id (sort {$a cmp $b} keys %result){
            print OUT ">", $id,"\n";
            for(my $i=0;$i < length($database{$id});$i +=80){
                print OUT substr($database{$id},$i,80),"\n";
            }
        }
        undef %tidy;
        undef %result;
    }

    my %gene;
    open GENE, "/home/katagirf/zhengq/Desktop/Soft/20170418_Color_and_Species.txt" or die "Can not open the file:$!";
    foreach (<GENE>){
        chomp;
        my @name = split;
        $gene{$name[0]} = $name[1]
    }
    foreach my $query (sort {$a cmp $b} keys %record){
       foreach my $id (sort {$a cmp $b} keys %{$record{$query}}){
            print $query,"\t",$gene{$id},"\t",$record{$query}{$id},"\n";
       }
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
   Usage: perl Top10_selection_20171107.pl [ -i Input_file ] [ -o Output_file ] [ -d database file name ] [ -n Integer ]
  Author: Qi Zheng, zhengq\@umn.edu
 Version: v1.0
 Command: -i Input file name(Required)
    	  -o Output file name(Required)
          -d Database file name(Required)
          -n Integer(default:3)
Function: Template for Perl
	\n!
	)
}


