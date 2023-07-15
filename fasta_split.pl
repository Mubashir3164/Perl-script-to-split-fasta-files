#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

# Get command-line options
my $input_file;
my $output_prefix;
my $num_files;

GetOptions(
    'input|i=s'   => \$input_file,
    'output|o=s'  => \$output_prefix,
    'num|n=i'     => \$num_files,
) or die "Usage: perl fasta_split.pl -i input_file.fasta -o output_prefix -n num_files\n";

# Check if required options are provided
unless ($input_file && $output_prefix && $num_files) {
    die "Usage: perl fasta_split.pl -i input_file.fasta -o output_prefix -n num_files\n";
}

# Read the input file
open my $fh, '<', $input_file or die "Unable to open input file: $!";
my @lines = <$fh>;
close $fh;

# Remove newline characters
chomp @lines;

# Create the output directory if it doesn't exist
my $output_dir = "split_files";
mkdir $output_dir unless -d $output_dir;

# Calculate the number of genes in the input file
my $num_genes = grep(/^>/, @lines);

# Calculate the number of genes per output file
my $genes_per_file = int($num_genes / $num_files);
$genes_per_file++ if ($num_genes % $num_files) != 0;

# Initialize variables
my $current_file = 1;
my $current_gene = 0;
my $output_file = "$output_dir/$output_prefix-split_$current_file.fasta";

# Open the first output file
open my $out_fh, '>', $output_file or die "Unable to create output file: $!";

# Loop through the lines of the input file
for my $line (@lines) {
    if ($line =~ /^>/) {
        $current_gene++;

        # Start a new output file if necessary
        if ($current_gene > $genes_per_file) {
            close $out_fh;
            $current_file++;
            $output_file = "$output_dir/$output_prefix-split_$current_file.fasta";
            open $out_fh, '>', $output_file or die "Unable to create output file: $!";
            $current_gene = 1;
        }

        # Print the header to the current output file
        print $out_fh "$line\n";
    } else {
        # Print the sequence to the current output file
        print $out_fh "$line\n";
    }
}

# Close the last output file
close $out_fh;

# Inform the user about the split files
print "Split files created in $output_dir directory.\n";