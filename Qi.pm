{ package Qi;
  use strict;
  use warnings;
  sub cons_database{
    my $file=shift;
    open FILE, "<$file" || die "$file can not be found";
    $/=">";
    my %gene;
    my @data=<FILE>;
    close FILE;
    shift @data;
    foreach my $each(@data){
      chomp $each;
      my @each_gene = split(/\n/,$each);
      my $gene_id = shift @each_gene;
      if(exists $gene{$gene_id}){
        warn "This file has at least two $gene_id";
      }else{
        $gene{$gene_id} = join("",@each_gene);
      }
    }
    $/="\n";
    return %gene;
  }
}
1;
