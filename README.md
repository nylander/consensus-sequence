# Calculate consensus sequence from fasta or CSV

- Last modified: tis sep 19, 2023  05:15
- Sign: JN

## Description

Two scripts for calculating consensus or compromise (DNA) sequences from either fasta or csv input format.

### consensus-seq.pl

            FILE: consensus-seq.pl

           USAGE: ./consensus-seq.pl fasta-alignment-file

     DESCRIPTION: Calculate consensus sequence from fasta alignment.
                  Can use a consensus level (1-100), or represent
                  a (strict) consensus using IUPAC symbols.

                  Prints to STDOUT or, if --outfile is used, to
                  an outfile.

                  Fasta sequence is wrapped to width set by -w,
                  (default 80), unless --nowrap is used.

                  Default fasta header will be based on infile
                  name, and will display some extra information.
                  For example:

                  >in.fas|consensus [conlevel=100 nseq=8 length=3844 identity=88.93]

                  The header can be overridden by using -l.

                  Regarding consensus level (taken from Bio::Align::AlignI):

                  "The consensus residue has to appear at least threshold %
                  of the sequences at a given location, otherwise a '?'
                  character will be placed at that location."

         OPTIONS: -i,--infile=<file>  Provide fasta formatted
                                      sequence alignment
                  -o,--oufile=<file>  Provide output file name
                                      (will be fasta format)
                  -c,--conlevel=<nr>  Provide consensus level (1-100).
                                      Default '50'.
                  -s,--strict         Synonym for -c=100. Overrides
                                      -c.
                  -l,--label=<string> Provide custom fasta header.
                  -w,--wrap=<nr>      Set max line length in sequence
                                      to <nr>. Default is 80.
                  -n,--nowrap         Do not wrap (interleave)
                                      sequence string.
                  -I,--IUPAC          Represent all ambiguities as 
                                      IUPAC symbols in the (strict)
                                      consensus.

    REQUIREMENTS: BioPerl, perldoc

            BUGS: ---

           NOTES: ---

          AUTHOR: Johan Nylander

         COMPANY: NRM

         VERSION: 1.0

         CREATED: 2019-09-25 09:42:04

        REVISION: ---

### consensus-seq-from-csv.pl

            FILE: consensus-from-csv.pl

           USAGE: ./consensus-seq-from-csv.pl R84150_2009.duplicates.csv
                  ./consensus-seq-from-csv.pl -d  R84150_2009.duplicates.csv
                  ./consensus-seq-from-csv.pl -s ';' R84150_2009.duplicates.txt
                  ./consensus-seq-from-csv.pl -s ';' -d  -nu dna.duplicates.txt

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

          AUTHOR: Johan Nylander

         COMPANY: NBIS/NRM

         VERSION: 1.0

         CREATED: 03/12/2019 11:02:49 AM

        REVISION: ---
