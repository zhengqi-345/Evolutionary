#!/usr/bin/perl
#===============================================================================
#         FILE: 20170831_fumi_strategy_V3.pl
#
#        USAGE: perl 20170831_fumi_strategy_V3.pl [ -i input file name ] 
#							 [ -o output file name ]
#						     [ ... ]
#
#       AUTHOR: Zheng Qi (zhengq)
#        EMAIL: zhengq@umn.edu
# ORGANIZATION: University of Minnesota, Twin Cities
#      CREATED: 08/31/2017 09:33:14 AM
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
	$/=">";
	my @blast_parse = <FILE>;
	my $query_name;
	my $query = shift @blast_parse;
	my @query = split(/\n/,$query);
    my %result;
	foreach my $line (@query){
		if($line =~ m/^Query=\s*(\S*)$/){
			$query_name = $1;
			$hash{$query_name}{query}{name} = $query_name;
		}
		if($line =~ m/^Length=([0-9]*)$/){
			$hash{$query_name}{query}{length} = $1;
		}
        if($line =~ m/^  (\S*)\s*[0-9]*\s*/){
            my $result = $1;
            if( exists $result{$result}){
                $result{$result}+=1;
            }else{
                $result{$result} = 0;
            }
        }
	}
	my $template = "-"x$hash{$query_name}{query}{length};
    print $hash{$query_name}{query}{length},"\n";
	foreach my $each (@blast_parse){
		chomp($each);
		my @each = split(/\n/,$each);
		my $subject_name = shift @each;
		$subject_name =~ s/\s//g;
		my $subj_len = shift @each;
		$subj_len =~ s/^Length=//g;
		$hash{$query_name}{subject}{$subject_name}{length} = $subj_len;
		$hash{$query_name}{subject}{$subject_name}{sequence} = $template;
		my $query_start = 0;
		my $query_seq;
		my $query_end;
		my $sbjct_start;
		my $sbjct_seq;
		my $sbjct_end;
		my @position;
		foreach my $line (@each){
			my $str = "-";
			my $offset = 0;
			my $position;
			if($line =~ m/^Query\s*([0-9]*)\s*([A-Z-]*)\s*([0-9]*)/){
				$query_start = $1;
				$query_seq   = $2;
				$query_end   = $3;
				$position = index($query_seq,$str,$offset);
				push @position,$position;
				until($position == -1){
					$offset = $position + 1;
					$position = index($query_seq,$str,$offset);
					push @position,$position;
				}
			}elsif($line =~ m/^Sbjct\s*([0-9]*)\s*([A-Z-]*)\s*([0-9]*)/g){
				$sbjct_start = $1;
				$sbjct_seq   = $2;
				$sbjct_end   = $3;
				foreach my $index(@position){
					if($index == -1){
						next;
					}else{
						substr($sbjct_seq,$index,1) = "=";
					}
				}
				undef @position;
				$sbjct_seq =~ s/=//g;
				substr($hash{$query_name}{subject}{$subject_name}{sequence},$query_start-1,length($sbjct_seq),$sbjct_seq);
			}
		}
		$hash{$query_name}{subject}{$subject_name}{sequence} =~ s/[Xx]/-/g;
		my $new_seq = $hash{$query_name}{subject}{$subject_name}{sequence};
		my $aa =($new_seq =~ s/[A-Z]/=/g);
		if(grep {$subject_name =~ /$_/} keys %result){
		    if($aa/length($new_seq) >= 0.3){
#		        print $subject_name,"\t",$aa,"\t",length($new_seq),"\t",$aa/length($new_seq),"\n";
                print OUT ">",$subject_name,"\n";
                for(my $i=0;$i<= length($hash{$query_name}{subject}{$subject_name}{sequence});$i+=80){
                    print OUT substr($hash{$query_name}{subject}{$subject_name}{sequence},$i,80),"\n";
                }
            }
		}
	}
}else{

	die "Error: there is improper parameter, please check it! \n";

}


