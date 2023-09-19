#!/usr/bin/env perl
#===============================================================================
=pod


=head2

         FILE: consensus-seq-from-csv.pl

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

=cut


#===============================================================================

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;

exec("perldoc", $0) unless (@ARGV);

my $space = ' ';
my $debug = 0;
my $separator = ',';
my $missing = '?';
my $nucleotide = 0;
my $fasta = 0;
my $label = q{};

GetOptions(
    "debug"       => \$debug,
    "separator:s" => \$separator,
    "missing:s"   => \$missing,
    "label:s"     => \$label,
    "nucleotide!" => \$nucleotide,
    "fasta"       => \$nucleotide,
    "help"        => sub { exec("perldoc", $0); exit(0); },
);


while (my $filename = shift) {
    my $seqid = q{};
    if($label) {
        $seqid = $label;
    }
    elsif ($filename =~ /^(\w+)\..*$/) {
        $seqid = $1;
    }
    else {
        die "Error: Could not get seqid from filename. Need to provide using --label option.\n";
    }
    open my $INFILE, "<", $filename or die "$!\n";
    my @lines = <$INFILE>;
    close($INFILE);
    chomp(@lines);

    my $maxlength = 0;
    foreach my $line (@lines) {
        next if ($line =~ /^\s*$/);
        $line =~ s/\s//g;
        my ($id, @char_array) = split /$separator/, $line;
        if (length($id) > $maxlength) {
            $maxlength = length($id);
        }
    }

    my %HoH = ();
    my @pos_array = ();

    foreach my $line (@lines) {
        next if ($line =~ /^\s*$/);
        $line =~ s/\s//g;
        my @char_array = split /$separator/, $line;
        my $id = shift @char_array;
        my $npad = $maxlength - length($id) + 1;
        my $pad = $space x $npad;
        if ($debug) {
            print STDERR $pad, $line, "\n";
        }
        my $position = 0;
        @pos_array = ();
        foreach my $character (@char_array) {
            $HoH{$position}{$character}++;
            push @pos_array, $position;
            $position++;
        }
    }

    if ($debug) {
        my $npad = $maxlength - length($seqid) + 1;
        my $pad = $space x $npad;
        print STDOUT $pad, $seqid, $separator;
    }
    else {
        print STDOUT $seqid, $separator;
    }
    foreach my $pos (@pos_array) {
        my $nkeys = scalar (keys %{$HoH{$pos}});
        if ($nkeys > 1) {
            if ($nucleotide) {
                my $ret = conseq(keys %{$HoH{$pos}});
                print STDOUT $ret;
            }
            else {
                print STDOUT '?';
            }
        }
        else {
            print keys %{$HoH{$pos}};
        }
        if (\$pos == \$pos_array[-1]) {
            # print no trailing ';'
        }
        else {
            print STDOUT $separator;
        }
    }
    print STDOUT "\n";
}


sub conseq {

    ## Input: array of unique DNA symbols (including IUPAC ambiguity codes)
    ## Return: a single letter

    ## IUPAC Code  Meaning           Complement
    ## A           A                 T
    ## C           C                 G
    ## G           G                 C
    ## T/U         T                 A
    ## M           A or C            K
    ## R           A or G            Y
    ## W           A or T            W
    ## S           C or G            S
    ## Y           C or T            R
    ## K           G or T            M
    ## V           A or C or G       B
    ## H           A or C or T       D
    ## D           A or G or T       H
    ## B           C or G or T       V
    ## N           G or A or T or C  N

    my (@input) = (@_);

    if ((scalar @input) == 1) {
        my $letter = shift(@input);
        return $letter;
    }

    my %return_hash = (
        'AC' => 'M',
        'AG' => 'R',
        'AT' => 'W',
        'CG' => 'S',
        'CT' => 'Y',
        'GT' => 'K',
        'ACG' => 'V',
        'ACT' => 'H',
        'AGT' => 'D',
        'CGT' => 'B',
        'ACGT' => 'N',
    );

    my %seq_hash = ();

    foreach my $seq (@input) {
        if (uc($seq) eq 'A') {
            $seq_hash{'A'}++;
        }
        if (uc($seq) eq 'C') {
            $seq_hash{'C'}++;
        }
        if (uc($seq) eq 'G') {
            $seq_hash{'G'}++;
        }
        if (uc($seq) eq 'T') {
            $seq_hash{'T'}++;
        }
        if (uc($seq) eq 'M') {
            $seq_hash{'A'}++;
            $seq_hash{'C'}++;
        }
        if (uc($seq) eq 'R') {
            $seq_hash{'A'}++;
            $seq_hash{'G'}++;
        }
        if (uc($seq) eq 'W') {
            $seq_hash{'A'}++;
            $seq_hash{'T'}++;
        }
        if (uc($seq) eq 'S') {
            $seq_hash{'C'}++;
            $seq_hash{'G'}++;
        }
        if (uc($seq) eq 'Y') {
            $seq_hash{'C'}++;
            $seq_hash{'T'}++;
        }
        if (uc($seq) eq 'K') {
            $seq_hash{'G'}++;
            $seq_hash{'T'}++;
        }
        if (uc($seq) eq 'V') {
            $seq_hash{'A'}++;
            $seq_hash{'C'}++;
            $seq_hash{'G'}++;
        };
        if (uc($seq) eq 'H') {
            $seq_hash{'A'}++;
            $seq_hash{'C'}++;
            $seq_hash{'T'}++;
        }
        if (uc($seq) eq 'D') {
            $seq_hash{'A'}++;
            $seq_hash{'G'}++;
            $seq_hash{'T'}++;
        }
        if (uc($seq) eq 'B') {
            $seq_hash{'C'}++;
            $seq_hash{'G'}++;
            $seq_hash{'T'}++;
        }
        if (uc($seq) eq 'N') {
            $seq_hash{'A'}++;
            $seq_hash{'C'}++;
            $seq_hash{'G'}++;
            $seq_hash{'T'}++;
        }
        if ($seq eq '?') {
            $seq_hash{'A'}++;
            $seq_hash{'C'}++;
            $seq_hash{'G'}++;
            $seq_hash{'T'}++
        }
        ;
        if ($seq eq '-') {
            $seq_hash{'A'}++;
            $seq_hash{'C'}++;
            $seq_hash{'G'}++;
            $seq_hash{'T'}++
        }
    }

    my $list = join('', sort keys %seq_hash);

    return $return_hash{$list};

}

__END__
