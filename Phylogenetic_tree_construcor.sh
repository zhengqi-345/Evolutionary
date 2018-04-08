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
