{
  package PhyTree
    use strict;
    use warnings;
    sub fasta_db{
    
      ##This subfunction was defined to construct PROTEIN/RNA/DNA sequence database. It will return a reference of hash;]
      ##Usage: my $var=PhyTree::fasta_db("proteinORdna_sequence_file.fasta");
      ##       $var->{"gene_ID"}
      
      my $file=shift;
      open FILE,"<$file" || die "Can not open the file:$!";
      $/=">";
      my %fasta;
      my @array=<FILE>;
      close FILE;
      shift @array;
      foreach my $line(@array){
        chomp $line;
        my @each_gene=split(/\n/,$line);
        my $gene_id=shift @each_gene;
        if(exists $fasta{$gene_id}){
          warn "$gene_id is duplicate sequence ID";
        }else{
          $fasta{$gene_id} = join("",@each_gene);
        }
      }
      $/="\n";
      return(\%fasta)
    }
    
    sub SeqOut{
    
      ##This is subroutine is definded to output a sequence file with fasta format.Three arguments are needed to provide by user.
      ##The first one is the file name to be output, the second is an integer controling line length, and the third is a hash reference storing sequences
      ##Usage  &SeqOut("output.file.name.fa",Integer,\%hash);
     
      my ($out,$length,$hash)=@_;
      open OUT,">$out" || die "Can not open the file:$!";
      foreach (sort {$a cmp $b } keys %{$hash}){
        print OUT ">",$_,"\n";
        for(my $i=0;$i<length($hash->{$_});$i+=$length){
          print OUT substr($hash->{$_},$i,$length),"\n";
        }
      }
    }
    
    sub cutoff{
      my ($file)=@_;
      open FILE,"<$file" || die "Can not open the file:$!";
      my %hash;
      
      foreach my $line (<FILE>){
        chomp($line);
        my @each_item=split(/\t/,$line);
        if(exists $hash{$each_item[0]}{$each_item[1]}{bitscore}){
          $hash{$each_item[0]}{$each_item[1]}{bitscore} += $each_item[11];
          $hash{$each_item[0]}{$each_item[1]}{length}   += ($each_item[9] - $each_item[8] + 1);
        }else{
          $hash{$each_item[0]}{$each_item[1]}{bitscore} = $each_item[11];
          $hash{$each_item[0]}{$each_item[1]}{length}   = ($each_item[9] - $each_item[8] + 1);
        }
      }
      
      my @query = keys %hash;
      my %cutoff;
      
      foreach my $query (@query){
        $cutoff{$query}{cutoff} =$hash{$query}{$query}{bitscore};
        foreach my $subj (@query){
          if($cutoff{$query}{cutoff} > $hash{$query}{$subj}{bitscore}){
            $cutoff($query){cutoff} = $hash{$query}{$subj}{bitscore};
            $cutoff($query){name}   = $subj;
          }else{
            next;
          }
        }
      }
      return(\%hash,\%cutoff);
    }
}
1;
