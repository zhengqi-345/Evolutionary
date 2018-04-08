#!/bin/bash
#PBS -l walltime=9:00:00,mem=10gb,nodes=1:ppn=4
#PBS -m abe
#PBS -M account@email.org
module load ncbi_blast+
module load mafft
module load clustalw
module load muscle
module load mrbayes
module load /panfs/roc/soft/modulefiles.common/raxml/8.2.11_pthread

function usage(){
	echo "bash $0 [ -q/--query ] [ -b/--blast_db ] [ -g/--genome_ref ] [ -o/--output ] [ -t/--tree_method ] [ -a/--alignment ] [ -s/--select ] [ -h/--help ] [ -v/--version ]"
	echo -e "\t -q/--query \tquery sequences file name"
	echo -e "\t -b/--blast_db \tprotein database of local blast"
	echo -e "\t -g/--genome_ref \tprotomic sequences of selected species (fasta format)"
	echo -e "\t -o/--output \toutput file name of tree file"
	echo -e "\t -t/--tree_method \tmethod used to construct phylogenetic trees(RAxML by default)"
	echo -e "\t -a/--alignment \tmultiple sequence alignments method(mafft by default)"
	echo -e "\t -s/--select \tmember selection method"
	echo -e "\t -h/--help \thelp"
	echo -e "\t -v/--version \tversion"
	exit 1
}

function help(){
	echo "bash $0 [ -q/--query ] [ -b/--blast_db ] [ -g/--genome_ref ] [ -o/--output ] [ -t/--tree_method ] [ -a/--alignment ] [ -s/--select ] [ -h/--help ] [ -v/--version ]"
	echo "For detail information, use follow command "
	echo "bash $0"
	exit 1
}

TREE_METHOD="raxmlHPC"
para=`getopt -o q:b:g:o:t:a:s:hv -l query:,blast_db:,genome_ref:,output:,tree_method:,alignment:,select:,help,version` --name "$0" -- "$@"
if [ $? != 0 ] echo "Terminate ... " >&2; exit 1; fi

eval set --"$para"

while true
do
	case "$1" in
		-q|--query)
			QUERY="$2"
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
		-s|--select)
			SELECT="$2"
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
while true
do
	case "$BLAST_DB" in 
		a)
			db="~/Public/blast_db/All_db"
			;;
		1)
			db="~/Public/blast_db/Liverwort_Moss_Lycophyte"
			;;
		2)
			db="~/Public/blast_db/Moss_Lycophyte_Fern"
			;;
		3)
			db="~/Public/blast_db/Lycophyte_Fern_Gymnosperm"
			;;
		4)
			db="~/Public/blast_db/Fern_Gymnosperm_Basal-most-Angiosperm"
			;;
		5)
			db="~/public/blast_db/Gymnosperm_Basal-most-Angiosperm_Magnoliid"
			;;
		6)
			db="~/Public/blast_db/Basal-most-Angiosperm_Magnoliid_Monocot"
			;;
		7)	
			db="~/Public/blast_db/Magnoliid_Monocot_Dicot"
		n)
			if [ -e "$GENOME_REF" ]
			then
				makeblastdb -in ${GENOME_REF} -out $(date "+%Y%m%d")-${GENOME_REF} -db_type prot --max_file_sz 1G
				db=$(date "+%Y%m%d")-${GENOME_REF}
			else
				echo "${GENOME_REF} does not exist"
				help
			fi
			;;
		*)
			echo "No proper blast data base found!"
			echo "Check blast database in \"~/Public/blast_db/\""
			exit 1;
	esac
done

blastp -query ${QUERY} -db ${db} -out ${QUERY}_blastp_${db}.out -evalue 1e-5 -outfmt 6

if [ "$SELECT" = "m" ]
then
	perl ~/Desktop/Software/Furthest_member_selection -i ${QUERY}_blastp_${db}.out -o ${QUERY}_blastp_${db}.fa -d ${fa}
elif [ "$SELECT" = "T3" ] || [ "$SELECT" = "t3" ]
then
	perl ~/Desktop/Software/Top3_select.pl -i ${QUERY}_blastp_${db}.out -o ${QUERY}_blastp_${db}.fa -d ${fa} -n 3
elif [ "$SELECT" = "T5" ] || [ "$SELECT" = "t5" ]
then 
	perl ~/Desktop/Software/Top3_select.pl -i ${QUERY}_blastp_${db}.out -o ${QUERY}_blastp_${db}.fa -d ${fa} -n 5
fi

if [ $(echo "$ALIGNMENT" |grep -i clustalw ) ]
then
	clustalw 
elif [ $(echo "$ALIGNMENT" |grep -i mafft ) ]
then
	mafft --maxiterate 1000 --globalpair ${QUERY}_blastp_${db}.fa >${QUERY}_blastp_${db}.aln
elif [ $(echo "$ALIGNMENT" |grep -i mrca ) ]
then
	num=$(grep -c ">" ${QUERY}_blastp_${db}.fa)
	makeblastdb -in ${QUERY}_blastp_${db}.fa -out ${QUERY}_blastp_${db} -db_type prot -max_file_sz 0.5G -num_alignments ${num} 
	blastp -query ${infile} -db ${QUERY}_blastp_${db} -out ${infile}_blastp_${QUERY}_${db}.out -evalue 1e-5 -num_alignments ${num}
	perl ~/Desktop/Software/MRCA_blastp.pl -i ${infile}_blastp_${QUERY}_${db}.out -o ${infile}_blastp_${QUERY}_${db}.fa
else
	echo "Multiple sequence alignment method NOT found"
	usage
fi

raxmlHPC-HYBRID -T 4 -n ${OUTPUT} -s ${infile} -c 25 -p 12345 -m PROTCATBLOSUM62 -k -f a -N 100 -x 12345
