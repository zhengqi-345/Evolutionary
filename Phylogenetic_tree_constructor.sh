#!/bin/bash
#PBS -l walltime=9:00:00,mem=10gb,nodes=1:ppn=4
#PBS -m abe
#PBS -M account@email.org
module load ncbi_blast+
module load mafft
module load clustalw
module load muscle
module load mrbayes
module load raxml

function usage(){
	echo "bash $0 [ -q/--query ] [ -b/--blast_db ] [ -g/--genome_ref ] [ -o/--output ] [ -t/--tree_method ] [ -a/--alignment ] [ -h/--help ] [ -v/--version ]"
	echo -e "\t -q/--query \tquery sequences file name"
	echo -e "\t -b/--blast_db \tprotein database of local blast"
	echo -e "\t -g/--genome_ref \tprotomic sequences of selected species (fasta format)"
	echo -e "\t -o/--output \toutput file name of tree file"
	echo -e "\t -t/--tree_method \tmethod used to construct phylogenetic trees(RAxML by default)"
	echo -e "\t -a/--alignment \tmultiple sequence alignments method(mafft by default)"
	echo -e "\t -h/--help \thelp"
	echo -e "\t -v/--version \tversion"
	exit 1
}

function help(){
	echo "bash $0 [ -q/--query ] [ -b/--blast_db ] [ -g/--genome_ref ] [ -o/--output ] [ -t/--tree_method ] [ -a/--alignment ] [ -h/--help ] [ -v/--version ]"
	echo "For detail information, use follow command "
	echo "bash $0"
	exit 1
}

para=`getopt -o q:b:g:o:t:a:hv -l query:,blast_db:,genome_ref:,output:,tree_method:,alignment:,help,version` --name "$0" -- "$@"
if [ $? != 0 ] echo "Terminate ... " >&2; exit 1; fi

eval set --"$para"

while true
do
	case "$1" in
		-q|--query)
			query="$2"
			shift 2
			;;
		-b|--blast_db)
			BLAST_DB="$2"
			shift 2
			;;
		-g|--genome_ref)
			GENOME_REF="$2"
			shift 2
			;;
		-o|--output)
			OUTPUT="$2"
			shift 2
			;;
		-t|--tree_method)
			TREE_METHOD="$2"
			shift 2
			;;
		-a|--alignment)
			ALIGNMENT="$2"
			shift 2
			;;
		-h|--help)
			help
			shift
			;;
		-v|--version)
			echo "Version 1.0.0"
			exit 1
			;;
		*)
			 usage
			 ;;
	esac
done
