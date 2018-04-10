#!/usr/bin/perl -w
#system("PERL5LIB=$PERL5LIB:~/Desktop/Soft/Perl_Module");
BEGIN{unshift @INC, "/home/katagirf/zhengq/Desktop/Soft/Perl_Module"};
#use lib "/home/katagirf/zhengq/Desktop/Soft/Perl_Module";
use strict;
use Getopt::Std;
use Qi;
use vars qw($opt_i $opt_o $opt_d);
getopts('i:o:d:');

if($opt_i && $opt_o && $opt_d){
		  open OUT,">$opt_o"|| die"Can not open the file: $!";
		  my %database = Qi::cons_database("$opt_d");
		  my @id = keys %database;
		  open NAME, "$opt_i" || die "Can not open the file:$!";
		  foreach my $target (<NAME>){
			  $target =~ s/\s//g;#chomp($target);
			  #print $target,"\n";
			 if(exists $database{$target}){
				 print OUT ">",$target,"\n";
				 for(my $i=0;$i <length($database{$target});$i+=80){
					 print OUT substr($database{$target},$i,80),"\n";
				 }
			 }
		  }
}else{
		  &usage;
}
sub usage{
		  print "perl extract_blast_sequenc.pl [-i <Input file>] [-o <Output file>] [-d <Database>]","\n";
		  print "-i input file name in current directory","\n";
		  print "-o output file name in current directory","\n";
		  print "-d the database file name in current directory","\n";
}
