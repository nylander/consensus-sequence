## 

            FILE: do_consensus.pl

           USAGE: ./do_consensus.pl R84150_2009.duplicates.csv
                  ./do_consensus.pl -d  R84150_2009.duplicates.csv
                  ./do_consensus.pl -s ';' R84150_2009.duplicates.txt
                  ./do_consensus.pl -s ';' -d  -nu dna.duplicates.txt

     DESCRIPTION: Read csv file and print "conservative consensus".
                  That is, if there are polymorphism in a site, a question mark
                  is printed.
                  Reads a file, prints to stdout.

         OPTIONS: -d, --debug      Will show the input sequences and consensus aligned.
                  -s, --separator  Define input (and output) separator (default ',').
                  -m, --missing    Define consensus symbol. Default '?'.
                  -n, --nucleotide Input are nucleotides. Will accept IUPAC ambiquity
                                   symbols.
                  -l, --label      Sequence label. If empty, will try to use file name.
                  -f, --fasta      Input is fasta.
                  -h, --help       Will show brief help text

    REQUIREMENTS: ---

            BUGS: ---

           NOTES: Uses the first part of the filename (<name>.duplicates.txt) as 
                  output sequence name, unless given as arg.

           TODO:  * Support fasta input
                  * Support AA input

          AUTHOR: Johan Nylander (JN), johan.nylander@nbis.se

         COMPANY: NBIS/NRM

         VERSION: 1.0

         CREATED: 03/12/2019 11:02:49 AM

        REVISION: ---
