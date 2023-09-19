#!/usr/bin/env perl
#===============================================================================

=pod


=head2

         FILE: consensus-seq.pl

        USAGE: ./consensus-seq.pl fasta-alignment-file

  DESCRIPTION: Calculate consensus sequence from fasta alignment.
               Can use a consensus level (1-100), or represent
               a (strict) consensus using IUPAC symbols.

               Prints to STDOUT or, if --outfile is used, to
               an outfile.

               Fasta sequence is wrapped (interleaved) to
               with set by -w, (default 80), unless
               --nowrap is used.

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

=cut

#===============================================================================

use strict;
use warnings;

use File::Basename;
use Bio::AlignIO;
use Bio::Align::AlignI;
use Getopt::Long qw(:config no_ignore_case);

exec("perldoc", $0) unless (@ARGV);

my $VERBOSE  = 0;
my $conldef  = 50;
my $conlevel = q{};
my $didlabel = 0;
my $format   = 'fasta';
my $infile   = q{};
my $iupac    = 0;
my $label    = q{};
my $nowrap   = 0;
my $outfile  = q{};
my $strict   = 0;
my $wrap     = 80;
my $PRINT_FH;
#my $informat  = 'fasta';
#my $outformat = 'fasta';

GetOptions(
    "IUPAC"      => \$iupac,
    "conlevel:i" => \$conlevel,
    "infile=s"   => \$infile,
    "label=s"    => \$label,
    "nowrap"     => \$nowrap,
    "outfile=s"  => \$outfile,
    "strict"     => \$strict,
    "verbose!"   => \$VERBOSE,
    "wrap:i"     => \$wrap,
    "help"       => sub {exec("perldoc", $0); exit(0);},
);

die
"Error: Need to provide an infile using the --infile argument.\nSee $0 --help.\n"
  unless ($infile);
die
"Error: Use either -I or -c.\nSee $0 --help.\n"
  if ($iupac and $conlevel);
die
"Error: Use either -I or --strict.\nSee $0 --help.\n"
  if ($iupac and $strict);

if (!$conlevel) {
    if ($strict) {
        $conlevel = 100;
    }
    else {
        $conlevel = $conldef;
    }
}

my $in = Bio::AlignIO->new(
    -file   => $infile,
    -format => $format
);

#my $out = Bio::AlignIO->new(
#    -file   => ">$outfile",
#    -format => $outformat
#);

my $basename = basename($infile);

if ($outfile) {
    open($PRINT_FH, '>', $outfile)
      or die "$0 : Failed to open output file $outfile : $!\n";
}
else {
    $PRINT_FH = *STDOUT;
}

if ($strict) {
    die "Error: Use either -I or --strict.\nSee $0 --help.\n"
      if ($iupac and $strict);
    $conlevel = 100;
}

while (my $aln = $in->next_aln()) {
    my $nseq     = $aln->num_sequences;
    my $length   = $aln->num_residues;
    my $identity = $aln->percentage_identity;
    my $seq      = q{};
    if ($label) {
        print $PRINT_FH ">", $label, "\n";
        $didlabel = 1;
    }
    if ($iupac) {
        print $PRINT_FH
          sprintf(">%s\|IUPAC consensus [nseq=%i length=%i identity=%.2f]\n",
            $basename, $nseq, $length, $identity)
          unless ($didlabel);
        $seq = $aln->consensus_iupac();
    }
    else {
        print $PRINT_FH
          sprintf(
            ">%s\|consensus [conlevel=%i nseq=%i length=%i identity=%.2f]\n",
            $basename, $conlevel, $nseq, $length, $identity)
          unless ($didlabel);
        $seq = $aln->consensus_string($conlevel);
    }
    $seq =~ s/\S{$wrap}/$&\n/g unless ($nowrap);
    print $PRINT_FH $seq, "\n";
}

if ($outfile) {
    close($PRINT_FH);
}

