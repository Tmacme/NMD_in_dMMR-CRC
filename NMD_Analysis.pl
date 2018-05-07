### NMD Analysis software, open source, created by I.T. Spaanderman, MIT licensing ###


use strict;
use warnings;
no warnings 'uninitialized';
use Spreadsheet::XLSX;
use Bio::EnsEMBL::Registry;
 
### PRINT PROGRAM INFORMATION ON SCREEN ###
print "\n\n----------------------------\n***NMD ANALYSIS SOFTWARE***\n----------------------------\nThank you for using NMD analysis tool v1.1. This tool is designed for the calculation of the effect 
of the Nonsense Mediated Decay Pathway by combining DNA and RNA sequencing data. For more information, including data requirements, please read NMD-analysis-software.pdf (github/...). \n
This program is open source and created by I.T. Spaanderman. \nOriginal publication: ...\n----------------------------\n";  
 
### CREATE EXPORT DOCUMENT AND PRINT HEADER INFORMATION IN FILE ###
open (my $fh, '>', 'NMD_analysis_export.txt');
my @header = ('Transcript input id', 'Sample id', 'Transcript ensembl id', 'Transcript refseq id', 'Transcript UCSC id', 'Mutation subtype', 'Mutation chromosome', 'Mutation start locus', 
	'Mutation end locus', 'Mutation length', 'Mutation strand', 'Mutation allel count', 'Wild type allel count', 'Variant allel frequency (VAF)', 'Corresponding Gene ID', 'Number of fetched transcripts by id', 
	'Number of transcripts in corresponding gene', 'Number of coding transcripts in corresponding gene', 'Number of transcripts on mutation locus', 'Number of coding transcripts on mutation locus', 
	'Exon id of mutation locus', 'Exon number of mutation locus', 'Exon total in transcript', 'Exon total coding in transcript', 'Number of first coding exon', 'Number of last coding exon', 
	'Number of exons after mutation', 'Number of coding exons after mutation', 'Location of mutation start in exon', 'Location of mutation start in cDNA', 'Distance of mutation from previous exon splice site', 
	'Distance of mutation from next exon splice site', 'Distance of mutation from last exon splice site in transcript', 'Distance of mutation from last coding exon splice site in transcript', 
	'Distance of mutation from transcript coding cdna end', 'Distance of mutation from transcript cdna end', 'Primary PTC sequence', 'Distance in Amino Acids between mutation and primary PTC', 
	'Amino Acids between mutation and primary PTC', 'Primary ptc locus in cdna', 'Primary ptc exon', 'Number of exon containing PTC', 'Number of exons after primary ptc', 'Number of coding exons after primary ptc', 
	'Distance of ptc from previous exon splice site', 'Distance of ptc from next exon splice site', 'Distance of ptc from last exon splice site in transcript', 
	'Distance of ptc from last coding exon splice site in transcript', 'Distance of ptc from transcript cdna end', 'Distance of ptc from transcript cdna coding end'); 
my $header_print = join("\t", @header); 
print $fh $header_print, "\n";
print "EXPORT DOCUMENT CREATED\nHEADER INFORMATION PRINTED\n";
 
### ASK USER TO PROVIDE INPUT ON DATA LOCATION ###
print "INPUT FROM USER REQUIRED\n----------------------------\nPlease specify the file containing DNA mutational data you want to analyse (only .xlsx files are accepted. the file must be located in the current directory): ";
my $dna_input_file_checked;
my $dna_input_file = <STDIN>;
if (rindex($dna_input_file, ".xlsx") != -1) {
    chomp $dna_input_file;
    $dna_input_file_checked = $dna_input_file;
}else{
    chomp $dna_input_file;
    $dna_input_file_checked = $dna_input_file . '.xlsx';
}
print "Please provide the ensembl version of your data (type 0 for GrCH38, type 1 for GrCH37): ";
my $ensembl_version = <STDIN>;
print "Please provide the number of rows that contain header information: ";
my $number_of_header_rows = <STDIN>;
print "Please provide the number of the column containing the transcript id: ";
my $transcript_id_column_input = <STDIN>;
my $transcript_id_column = $transcript_id_column_input - 1;
print "Please provide the number of the column containing the sample id: ";
my $sample_id_column_input = <STDIN>;
my $sample_id_column = $sample_id_column_input - 1;
print "Please provide the number of the column containing mutation subtype: ";
my $mutation_subtype_column_input = <STDIN>;
my $mutation_subtype_column = $mutation_subtype_column_input - 1;
print "Please provide the number of the column containing the mutation chormosome: ";
my $mutation_chromosome_column_input = <STDIN>;
my $mutation_chromosome_column = $mutation_chromosome_column_input - 1;
print "Please provide the number of the column containing the mutation start coordinate: ";
my $mutation_start_column_input = <STDIN>;
my $mutation_start_column = $mutation_start_column_input - 1;
print "Please provide the number of the column containing the mutation end coordinate: ";
my $mutation_end_column_input = <STDIN>;
my $mutation_end_column = $mutation_end_column_input - 1;
print "Please provide the number of the column containing the mutation allel count: ";
my $mutation_allel_count_column_input = <STDIN>;
my $mutation_allel_count_column = $mutation_allel_count_column_input - 1;
print "Please provide the number of the column containing the wild type allel count: ";
my $wild_type_allel_count_column_input = <STDIN>;
my $wild_type_allel_count_column = $wild_type_allel_count_column_input - 1;
print "Please provide the transcripts you would like to analyse (type 0 for all transcripts on mutation locus, type 1 for transcripts according to external ID): ";
my $analysis_method = <STDIN>;
print "Please provide if you would like to use this analysing software to parse the expression vallues (type 0 for false, type 1 for true): ";
my $parsing_status = <STDIN>;
my $rna_input_file_checked;
my $rna_input_file_sample_id_identifier;
if ($parsing_status == 1){
	print "Please specify the file containing RNA transcript expression data you want to analyse (only .xlsx files are accepted. the file must be located in the current directory): ";
	my $rna_input_file = <STDIN>;
	if (rindex($rna_input_file, ".xlsx") != -1) {
		chomp $rna_input_file;
		$rna_input_file_checked = $rna_input_file;
	}else{
		chomp $rna_input_file;
		$rna_input_file_checked = $rna_input_file . '.xlsx';
	}
	print "Please provide the sample id indentifier in RNA data (type 0 for Ensembl, type 1 for UCSC, type 2 for RefSeq): ";
	$rna_input_file_sample_id_identifier = <STDIN>; 
}
print "----------------------------\nINPUT STORED\n";
 
### LOAD SELECTED TABLES ###
my $mutation_xlsx;
my $expression_xlsx;
if ($parsing_status == 0){
	print "LOADING IMPORT TABLE\n";
	$mutation_xlsx = Spreadsheet::XLSX->new($dna_input_file_checked);
	print "LOADED IMPORT TABLE SUCCESFULL\n";
}elsif ($parsing_status == 1){
	print "LOADING IMPORT TABLE\n";
	$mutation_xlsx = Spreadsheet::XLSX->new($dna_input_file_checked);
	$expression_xlsx = Spreadsheet::XLSX->new($rna_input_file_checked);
	print "LOADED IMPORT TABLE SUCCESFULL\n";
}
 
### LOG IN TO ENSEMBL API AND RETRIEVE ADAPTORS###
print "LOGING IN TO ENSEMBLE API\n";
my $registry = "Bio::EnsEMBL::Registry";
if ($ensembl_version == 1){
$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous',
    -species => 'homo_sapiens',
    -port => 3337,
    );
}else{
$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous',
    -species => 'homo_sapiens',
    );
}
my $transcript_adaptor = Bio::EnsEMBL::Registry->get_adaptor( 'Human', 'Core', 'Transcript' );
my $slice_adaptor = $registry->get_adaptor('Human', 'Core', 'Slice');
print "LOG IN SUCCESFULL\n";
 
### ACQUIRE DATA AND START ANALYSIS PER ROW ###
print "STARTING ANALYSIS PER ROW\n----------------------------\n";
     
foreach my $mutation_sheet (@{$mutation_xlsx->{Worksheet}}) {
    $mutation_xlsx -> {MaxRow} ||= $mutation_xlsx -> {MinRow};
     
    foreach my $mutation_row ($mutation_sheet -> {MinRow} .. $mutation_sheet -> {MaxRow}) {
        print $mutation_row, "/", $mutation_sheet -> {MaxRow}, "\n";
         
        ### SKIP ROWS CONTAINING HEADER ###
        if ($mutation_row >= $number_of_header_rows){
             
            ### CREATE EMPTY ARRAY IN ORDER TO STORE DATA FOR PRINTING LATER ###
            my @data_array;
             
            ### IMPORT DATA FROM TABLE ###
            my $transcript_id_cell = $mutation_sheet -> {Cells} [$mutation_row] [$transcript_id_column];
            my $transcript_id_value = $transcript_id_cell -> {Val};
            my $sample_id_cell = $mutation_sheet -> {Cells} [$mutation_row] [$sample_id_column];
            my $sample_id_value = $sample_id_cell -> {Val};
            my $mutation_subtype_cell = $mutation_sheet -> {Cells} [$mutation_row] [$mutation_subtype_column];
            my $mutation_subtype_value = $mutation_subtype_cell -> {Val};
			my $mutation_chromosome_cell = $mutation_sheet -> {Cells} [$mutation_row] [$mutation_chromosome_column];
            my $mutation_chromosome_value = $mutation_chromosome_cell -> {Val};
			my $mutation_start_cell = $mutation_sheet -> {Cells} [$mutation_row] [$mutation_start_column];
            my $mutation_start_value = $mutation_start_cell -> {Val};
			my $mutation_end_cell = $mutation_sheet -> {Cells} [$mutation_row] [$mutation_end_column];
            my $mutation_end_value = $mutation_end_cell -> {Val};
			my $mutation_allel_count_cell = $mutation_sheet -> {Cells} [$mutation_row] [$mutation_allel_count_column];
            my $mutation_allel_count_value = $mutation_allel_count_cell -> {Val};
			my $wild_type_allel_count_cell = $mutation_sheet -> {Cells} [$mutation_row] [$wild_type_allel_count_column];
            my $wild_type_allel_count_value = $wild_type_allel_count_cell -> {Val};
			
			### CALCULATE ADDITIONAL MUTATIONAL PROPERTIES ###
			my $mutation_length = $mutation_end_value - $mutation_start_value;
				if ($mutation_length < 0){
					$mutation_length = $mutation_length * -1;
				}else{
				}
			$mutation_length = $mutation_length + 1;
			
			my $variant_allel_frequency = $mutation_allel_count_value / ($wild_type_allel_count_value + $mutation_allel_count_value) * 100;
				
			### RETRIEVE TRANSCRIPT INFORMATION FROM ENSEBML BY LOCUS ###
			my $slice = $slice_adaptor->fetch_by_region('chromosome', $mutation_chromosome_value, $mutation_start_value, $mutation_end_value);
			my @transcripts_by_locus = @{ $slice->get_all_Transcripts() };
			my $number_of_transcripts_on_locus = scalar @transcripts_by_locus;
			my $number_of_coding_transcripts_on_locus;
			foreach my $transcript_by_locus (@transcripts_by_locus){
				my $transcript_by_locus_coding_status = $transcript_by_locus->biotype;																											
				if ($transcript_by_locus_coding_status eq "protein_coding"){
					$number_of_coding_transcripts_on_locus++;
				}else{
				}
			}
			
			### RETRIEVE TRANSCRIPT INFORMATION FROM ENSEMBL BY EXTERNAL ID ###
			my $transcript = $transcript_adaptor->fetch_by_stable_id($transcript_id_value);
			my $number_of_fetched_transcripts = 1;
			
			### DESIGNATE EMPTY VARIABLES FOR CORRESPONDING GENE INFORMATION ###
			my $last_corresponding_gene_id;
			my $number_of_transcripts_in_corresponding_gene;
			my $number_of_coding_transcripts_in_corresponding_gene;
				
				### SELECT EITHER LOCUS OR EXTERNAL ID AS SOURCE FOR TRANSCRIPT ANALYSIS ###
				my @selected_transcripts;
				if ($analysis_method == 1){

				}else{
					@selected_transcripts = @transcripts_by_locus;
				}
				
				### START ANALYSIS FOR EACH CODING TRANSCRIPT ###
			
					my $transcript_coding_status = $transcript->biotype;
					if ($transcript_coding_status eq "protein_coding" ){
					
						### COLLECT REFERENCE ID'S ###
						my @refseq_transcript_ids;
						my @refseq_xrefs = @{ $transcript->get_all_xrefs('Refseq%') };
							foreach my $refseq_xref (@refseq_xrefs){
							my $refseq_xref_id = $refseq_xref->display_id;
							push @refseq_transcript_ids, $refseq_xref_id;
							}
						my $refseq_transcript_id = join("|", @refseq_transcript_ids); 
					
						my @UCSC_transcript_ids;
						my @UCSC_xrefs = @{ $transcript->get_all_xrefs('UCSC%') };
							foreach my $UCSC_xref (@UCSC_xrefs){
							my $UCSC_xref_id = $UCSC_xref->display_id;
							push @UCSC_transcript_ids, $UCSC_xref_id;
							}
						my $UCSC_transcript_id = join("|", @UCSC_transcript_ids);

						my $ensembl_transcript_id = $transcript->display_id;
					
						### COLLECT CORRESPONDING GENE INFORMATION IF NOT SIMILAR TO LAST TRANSCRIPT###
						my $corresponding_gene = $transcript->get_Gene;
						my $corresponding_gene_id = $corresponding_gene->display_id;
											
						if ($corresponding_gene_id ne $last_corresponding_gene_id){
							$last_corresponding_gene_id = $corresponding_gene_id;
							my @corresponding_gene_transcripts = @{ $corresponding_gene->get_all_Transcripts };
							$number_of_transcripts_in_corresponding_gene = scalar @corresponding_gene_transcripts;
							foreach my $corresponding_gene_transcript (@corresponding_gene_transcripts){
								my $corresponding_gene_transcript_coding_status = $corresponding_gene_transcript->biotype;
								if ($corresponding_gene_transcript_coding_status eq "protein_coding"){
									$number_of_coding_transcripts_in_corresponding_gene++;
								}else{
								}
							}
						}
						
						### COLLECT ALL EXONS IN TRANSCRIPT AND CALCULATED NUMBER OF (CODING) EXONS IN TRANSCRIPT ###
						my @exons = @{ $transcript->get_all_Exons() };
						my $transcript_strand = $transcript->strand;
						my $number_exons_in_transcript = scalar @exons;
						my $first_coding_exon = 0;
						my $last_coding_exon;
						my $mutation_containing_exon;
						my $exon_counter = 0;
						my $exon_containing_mutation;
						my $exon_containing_mutation_id;
						my $exon_number_containing_mutation;
						my $last_coding_exon_ensembl_id;
						my $last_exon_ensembl_id;
						my @exons_ensembl_hash;
						my @exons_ensembl_id;
						my @exons_cdna_coding_start;
						my @exons_cdna_coding_ends;
						my @exons_cdna_start;
						my @exons_cdna_end;
						my $ptc_containing_exon;
						my $number_of_exon_containing_primary_ptc;
						my $ptc_containing_exon_id;
						my $primary_ptc_locus_in_cdna;
						my $primary_ptc_exon;
						my $number_of_exons_after_primary_ptc;
						my $number_of_coding_exons_after_primary_ptc;
						my $distance_of_ptc_from_previous_exon_splice_site;
						my $distance_of_ptc_from_next_exon_splice_site;
						my $distance_of_ptc_from_last_exon_splice_site_in_transcript;
						my $distance_of_ptc_from_last_coding_exon_splice_site_in_transcript;
						my $distance_of_ptc_from_transcript_cdna_end;
						my $distance_of_ptc_from_transcript_cdna_coding_end;
																	
						foreach my $exon (@exons){
							$exon_counter++;
							my $exon_cdna_coding_start = $exon->cdna_coding_start($transcript);
							my $exon_cdna_coding_end = $exon->cdna_coding_end($transcript);
							my $exon_cdna_start = $exon->cdna_start($transcript);
							my $exon_cdna_end = $exon->cdna_end($transcript);
							my $exon_ensembl_id = $exon->display_id;
							
							if ($exon_cdna_coding_start > 0 && $exon_cdna_coding_end > 0){
								$last_coding_exon = $exon_counter;
								$last_coding_exon_ensembl_id = $exon;
								
								if ($first_coding_exon == 0){
									$first_coding_exon = $exon_counter;
								}else{
								}
							}else{
							}
							
							if ($exon_counter == $number_exons_in_transcript){
								$last_exon_ensembl_id = $exon;
							}else{
							}
														
							### IDENTIFY EXON CONTAINING MUTATION ###
							my $exon_seq_region_start = $exon->seq_region_start;
							my $exon_seq_region_end = $exon->seq_region_end;
														
							if ($transcript_strand == 1){
								if ($exon_seq_region_start <= $mutation_start_value && $mutation_end_value <= $exon_seq_region_end){
									$exon_containing_mutation = $exon;
									$exon_containing_mutation_id = $exon_ensembl_id;
									$exon_number_containing_mutation = $exon_counter;
								}else{
								}
							}elsif ($transcript_strand == -1){
								if ($exon_seq_region_start <= $mutation_end_value && $mutation_start_value <= $exon_seq_region_end){
									$exon_containing_mutation = $exon;
									$exon_containing_mutation_id = $exon_ensembl_id;
									$exon_number_containing_mutation = $exon_counter;
								}else{
								}
							}
							
							### STORE EXON VALUES FOR LATER USE IN PTC LOCALISATION ###
							push @exons_ensembl_hash, $exon;
							push @exons_ensembl_id, $exon_ensembl_id;
							push @exons_cdna_coding_start, $exon_cdna_coding_start;
							push @exons_cdna_coding_ends, $exon_cdna_coding_end;
							push @exons_cdna_start, $exon_cdna_start;
							push @exons_cdna_end, $exon_cdna_end;
							
						}
						
						if (defined $exon_containing_mutation){
							### CALCULATE RELATIVE POSITION OF MUTATION AND EXON IN TRANSCRIPT ###
							my $number_of_exons_after_mutation = $number_exons_in_transcript - $exon_number_containing_mutation;
							my $number_of_coding_exons = $last_coding_exon - $first_coding_exon + 1;
							my $number_of_coding_exons_after_mutation = $last_coding_exon - $exon_number_containing_mutation;
							my $last_splice_site_in_cdna = $last_exon_ensembl_id->cdna_start($transcript);
							my $last_coding_splice_site_in_cdna = $last_coding_exon_ensembl_id->cdna_start($transcript);
							my $mutation_point_in_cdna;
							my $mutation_point_in_exon;
																			
							### COLLECT PROPERTIES AND SEQUENCE OF EXON/TRANSCRIPT CONTAINING MUTATION ###
							my $transcript_sequence = $transcript->seq->seq;
							my $exon_containing_mutation_seq_region_start = $exon_containing_mutation->seq_region_start;
							my $exon_containing_mutation_seq_region_end = $exon_containing_mutation->seq_region_end;
							my $exon_containing_mutation_cdna_start = $exon_containing_mutation->cdna_start($transcript);
							my $exon_containing_mutation_cdna_end = $exon_containing_mutation->cdna_end($transcript);
							my $transcript_cdna_coding_start = $transcript->cdna_coding_start;
							my $transcript_cdna_coding_end = $transcript->cdna_coding_end;
							my $transcript_cdna_length = $transcript->length;
							
							### CALCULATE PRIMARY PTC BY STRAND AND MUTATION SUBTYPE ###
							my $primary_ptc_distance_in_amino_acids;
							my $absolute_primary_ptc_distance;
							my $primary_ptc_sequence;
							my $amino_acids_covered_in_ptc_search = 0;
							my @amino_acids_between_mutation_and_ptc;
							
							if ($transcript_strand == 1){
								$mutation_point_in_exon = $mutation_start_value - $exon_containing_mutation_seq_region_start;
							}elsif ($transcript_strand == -1){
								$mutation_point_in_exon = $mutation_end_value - $exon_containing_mutation_seq_region_end;
							}else{
							}
								
							$mutation_point_in_cdna = $mutation_point_in_exon + $exon_containing_mutation_cdna_start;
							my $mutation_point_in_coding_cdna = $mutation_point_in_cdna - $transcript_cdna_coding_start;
								
							my $mutation_sequence = substr $transcript_sequence, $mutation_point_in_cdna, $mutation_length;
								
							### CALCULATE MUTATION POSITION IN READING FRAME AND ADJUST FOR MUTATION LENGTH AND SUBTYPE###
							my $adjusted_ptc_search_point;
							my $mutation_point_in_reading_frame_addon;
							my $mutation_point_in_reading_frame_1 = $mutation_point_in_coding_cdna / 3;
							my $mutation_point_in_reading_frame_2 = ($mutation_point_in_coding_cdna - 1) / 3;
							my $mutation_point_in_reading_frame_3 = ($mutation_point_in_coding_cdna - 2) / 3;
								
							if ($mutation_point_in_reading_frame_1 =~ /^\d+$/){
								$mutation_point_in_reading_frame_addon = 0; 
							}elsif ($mutation_point_in_reading_frame_2 =~ /^\d+$/){
								$mutation_point_in_reading_frame_addon = 1;
							}elsif ($mutation_point_in_reading_frame_3 =~ /^\d+$/){
								$mutation_point_in_reading_frame_addon = 2;
							}else{
							}    
							
							if ($mutation_subtype_value =~ /Ins/){
								my $mutation_length_adjusted_for_reading_frame = $mutation_length;
								until ($mutation_length_adjusted_for_reading_frame <= 3) {
									$mutation_length_adjusted_for_reading_frame = $mutation_length_adjusted_for_reading_frame - 3;
								}
								my $mutation_length_in_reading_frame_addon = 3 - $mutation_length_adjusted_for_reading_frame;
								$adjusted_ptc_search_point = $mutation_point_in_coding_cdna - $mutation_point_in_reading_frame_addon + $mutation_length_in_reading_frame_addon;							
							}elsif ($mutation_subtype_value =~ /Del/){
								$adjusted_ptc_search_point = $mutation_point_in_coding_cdna - $mutation_point_in_reading_frame_addon + $mutation_length + 3;
							}else{
							}
									
							### SEARCH FOR PRIMARY PTC IN DELETIONS AND INSERTIONS ###
							if ($mutation_subtype_value =~ /Ins/ || $mutation_subtype_value =~ /Del/){
								my $ptc_found = 0;
								my $ptc_search_sequence = substr $transcript_sequence, $adjusted_ptc_search_point, 3;
								until ($ptc_found == 1 || $ptc_search_sequence eq undef){
									if ($ptc_search_sequence eq 'TAG' || $ptc_search_sequence eq 'TAA' || $ptc_search_sequence eq 'TGA'){
										$amino_acids_covered_in_ptc_search++;
										$primary_ptc_sequence = $ptc_search_sequence;
										$primary_ptc_distance_in_amino_acids = $amino_acids_covered_in_ptc_search;
										$ptc_found++;
									}else{
										$amino_acids_covered_in_ptc_search++;
											
										### IDENTIFY AMINO ACIDS BETWEEN MUTATION AND PRIMARY PTC ###
										if ($ptc_search_sequence eq 'TTT' || $ptc_search_sequence eq 'TTC'){
											push @amino_acids_between_mutation_and_ptc, 'PHE';
										}elsif ($ptc_search_sequence eq 'TTA' || $ptc_search_sequence eq 'TTG' || $ptc_search_sequence eq 'CTT' || $ptc_search_sequence eq 'CTC' || $ptc_search_sequence eq 'CTA' || $ptc_search_sequence eq 'CTG'){
											push @amino_acids_between_mutation_and_ptc, 'LEU';
										}elsif ($ptc_search_sequence eq 'ATT' || $ptc_search_sequence eq 'ATC' || $ptc_search_sequence eq 'ATA'){
											push @amino_acids_between_mutation_and_ptc, 'ILE';
										}elsif ($ptc_search_sequence eq 'ATG'){
											push @amino_acids_between_mutation_and_ptc, 'MET';
										}elsif ($ptc_search_sequence eq 'GTT' || $ptc_search_sequence eq 'GTC' || $ptc_search_sequence eq 'GTA' || $ptc_search_sequence eq 'GTG'){
											push @amino_acids_between_mutation_and_ptc, 'VAL';
										}elsif ($ptc_search_sequence eq 'TCT' || $ptc_search_sequence eq 'TCC' || $ptc_search_sequence eq 'TCA' || $ptc_search_sequence eq 'TCG'){
											push @amino_acids_between_mutation_and_ptc, 'SER';
										}elsif ($ptc_search_sequence eq 'CCT' || $ptc_search_sequence eq 'CCC' || $ptc_search_sequence eq 'CCA' || $ptc_search_sequence eq 'CCG'){
											push @amino_acids_between_mutation_and_ptc, 'PRO';
										}elsif ($ptc_search_sequence eq 'ACT' || $ptc_search_sequence eq 'ACC' || $ptc_search_sequence eq 'ACA' || $ptc_search_sequence eq 'ACG'){
											push @amino_acids_between_mutation_and_ptc, 'THR';
										}elsif ($ptc_search_sequence eq 'GCT' || $ptc_search_sequence eq 'GCC' || $ptc_search_sequence eq 'GCA' || $ptc_search_sequence eq 'GCG'){
											push @amino_acids_between_mutation_and_ptc, 'ALA';
										}elsif ($ptc_search_sequence eq 'TAT' || $ptc_search_sequence eq 'TAC'){
											push @amino_acids_between_mutation_and_ptc, 'TYR';
										}elsif ($ptc_search_sequence eq 'CAT' || $ptc_search_sequence eq 'CAC'){
											push @amino_acids_between_mutation_and_ptc, 'HIS';
										}elsif ($ptc_search_sequence eq 'CAA' || $ptc_search_sequence eq 'CAG'){
											push @amino_acids_between_mutation_and_ptc, 'GIN';	
										}elsif ($ptc_search_sequence eq 'AAT' || $ptc_search_sequence eq 'AAC'){
											push @amino_acids_between_mutation_and_ptc, 'ASN';
										}elsif ($ptc_search_sequence eq 'AAA' || $ptc_search_sequence eq 'AAG'){
											push @amino_acids_between_mutation_and_ptc, 'LYS';
										}elsif ($ptc_search_sequence eq 'GAT' || $ptc_search_sequence eq 'GAC'){
											push @amino_acids_between_mutation_and_ptc, 'ASP';
										}elsif ($ptc_search_sequence eq 'GAA' || $ptc_search_sequence eq 'GAG'){
											push @amino_acids_between_mutation_and_ptc, 'GLU';
										}elsif ($ptc_search_sequence eq 'TGT' || $ptc_search_sequence eq 'TGC'){
											push @amino_acids_between_mutation_and_ptc, 'CYS';
										}elsif ($ptc_search_sequence eq 'TGG'){
											push @amino_acids_between_mutation_and_ptc, 'TRP';
										}elsif ($ptc_search_sequence eq 'AGA' || $ptc_search_sequence eq 'AGG' || $ptc_search_sequence eq 'CGT' || $ptc_search_sequence eq 'CGC' || $ptc_search_sequence eq 'CGA' || $ptc_search_sequence eq 'CGG'){
											push @amino_acids_between_mutation_and_ptc, 'ARG';
										}elsif ($ptc_search_sequence eq 'AGT' || $ptc_search_sequence eq 'AGC'){
											push @amino_acids_between_mutation_and_ptc, 'SER';
										}elsif ($ptc_search_sequence eq 'GGT' || $ptc_search_sequence eq 'GGC' || $ptc_search_sequence eq 'GGA' || $ptc_search_sequence eq 'GGG'){
											push @amino_acids_between_mutation_and_ptc, 'GLY';
										}else{
										}
												
										$adjusted_ptc_search_point = $adjusted_ptc_search_point + 3;
										$ptc_search_sequence = substr $transcript_sequence, $adjusted_ptc_search_point, 3;
									}
								}
									
								### CALCULATE ABSOLUTE DISTANCE OF PRIMARY PTC IN BASEPAIR ###
								my $absolute_primary_ptc_distance_corrected_for_mutation_length;
								if ($mutation_subtype_value =~ /Ins/){
									$absolute_primary_ptc_distance = ($primary_ptc_distance_in_amino_acids * 3) + $mutation_point_in_reading_frame_addon + $mutation_length;
									$absolute_primary_ptc_distance_corrected_for_mutation_length = $absolute_primary_ptc_distance - $mutation_length;
								}elsif ($mutation_subtype_value =~ /Del/){
									$absolute_primary_ptc_distance = ($primary_ptc_distance_in_amino_acids * 3) + $mutation_point_in_reading_frame_addon;
									$absolute_primary_ptc_distance_corrected_for_mutation_length = $absolute_primary_ptc_distance + $mutation_length;
								}else{
								}
								
								### FIND EXON CONTAINING MUTATION ###
								my $exon_counter_lv1 = 0;
								my $exon_counter_compl = 0;
								my $exon_ptc_counter = 0;
								my $exon_containing_ptc;
								foreach my $exon_cdna_start (@exons_cdna_start){
									$exon_counter_lv1++;
									if ($exon_cdna_start <= $absolute_primary_ptc_distance_corrected_for_mutation_length){
										my $exon_counter_lv2 = 0;
										foreach my $exon_cdna_end (@exons_cdna_end){
											$exon_counter_lv2++;
											if ($exon_counter_lv1 == $exon_counter_lv2){
												if ($exon_cdna_end >= $absolute_primary_ptc_distance_corrected_for_mutation_length){
													$exon_counter_compl = $exon_counter_lv2;
												}else{
												}
											}else{
											}
										}
									}else{
									}
								}
								foreach my $exon_ensembl_hash (@exons_ensembl_hash){
									$exon_ptc_counter++;
									if ($exon_ptc_counter == $exon_counter_compl){
										$exon_containing_ptc = $exon_ensembl_hash;
									}else{
									}
								}
									
								### DETERMINE PROPERTIES AND POSITION OF PTC IN EXON AND TRANSCRIPT ###
								my $exon_containing_mutation_cdna_start;
								my $exon_containing_mutation_cdna_end;
								if (defined $exon_containing_ptc){
									$exon_containing_mutation_cdna_start = $exon_containing_ptc->cdna_start($transcript);
									$exon_containing_mutation_cdna_end = $exon_containing_ptc->cdna_end($transcript);
									$primary_ptc_locus_in_cdna = $absolute_primary_ptc_distance_corrected_for_mutation_length;
									$primary_ptc_exon = $exon_containing_ptc->display_id;
									$number_of_exon_containing_primary_ptc = $exon_counter_compl;
									$number_of_exons_after_primary_ptc = $number_exons_in_transcript - $exon_counter_compl;
									$number_of_coding_exons_after_primary_ptc = $last_coding_exon - $exon_counter_compl;
									$distance_of_ptc_from_previous_exon_splice_site = $absolute_primary_ptc_distance_corrected_for_mutation_length - $exon_containing_mutation_cdna_start;
									$distance_of_ptc_from_next_exon_splice_site = $exon_containing_mutation_cdna_end - $absolute_primary_ptc_distance_corrected_for_mutation_length;
									$distance_of_ptc_from_last_exon_splice_site_in_transcript = $last_splice_site_in_cdna - $absolute_primary_ptc_distance_corrected_for_mutation_length;
									$distance_of_ptc_from_last_coding_exon_splice_site_in_transcript = $last_coding_splice_site_in_cdna - $absolute_primary_ptc_distance_corrected_for_mutation_length;
									$distance_of_ptc_from_transcript_cdna_end = $transcript_cdna_length - $absolute_primary_ptc_distance_corrected_for_mutation_length;
									$distance_of_ptc_from_transcript_cdna_coding_end = $transcript_cdna_coding_end - $absolute_primary_ptc_distance_corrected_for_mutation_length; 
								}else{
								}
							
							}elsif ($mutation_subtype_value =~ /Nonsense/){
								$primary_ptc_distance_in_amino_acids = 0;
								$absolute_primary_ptc_distance = 0;
							}else{
							}
																																							
							### CALCULATE RELATIVE POSITION OF MUTATION IN CDNA ###			
							my $distance_of_mutation_start_from_previous_splice_site = $mutation_point_in_cdna - $exon_containing_mutation_cdna_start;
							my $distance_of_mutation_start_from_next_splice_site = $exon_containing_mutation_cdna_end - $mutation_point_in_cdna;
							my $distance_of_mutation_start_from_last_splice_site = $last_splice_site_in_cdna - $mutation_point_in_cdna;
							my $distance_of_mutation_start_from_last_coding_splice_site = $last_coding_splice_site_in_cdna - $mutation_point_in_cdna;    
							my $distance_of_mutation_start_from_coding_cdna_end = $transcript_cdna_coding_end - $mutation_point_in_cdna;
							my $distance_of_mutation_start_from_cdna_end = $transcript_cdna_length - $mutation_point_in_cdna;
							
							### DETERMINE LOCUS PTC FOR NONSENSE MUTATION ###
							if ($mutation_subtype_value =~ /Nonsense/){
								$primary_ptc_locus_in_cdna = $mutation_point_in_cdna;
								$primary_ptc_exon = $exon_containing_mutation_id;
								$number_of_exon_containing_primary_ptc = $exon_number_containing_mutation;
								$number_of_exons_after_primary_ptc = $number_of_exons_after_mutation;
								$number_of_coding_exons_after_primary_ptc = $number_of_coding_exons_after_mutation;
								$distance_of_ptc_from_previous_exon_splice_site = $distance_of_mutation_start_from_previous_splice_site;
								$distance_of_ptc_from_next_exon_splice_site = $distance_of_mutation_start_from_next_splice_site;
								$distance_of_ptc_from_last_exon_splice_site_in_transcript = $distance_of_mutation_start_from_last_splice_site;
								$distance_of_ptc_from_last_coding_exon_splice_site_in_transcript = $distance_of_mutation_start_from_last_coding_splice_site;
								$distance_of_ptc_from_transcript_cdna_end = $distance_of_mutation_start_from_cdna_end;
								$distance_of_ptc_from_transcript_cdna_coding_end = $distance_of_mutation_start_from_coding_cdna_end;
							}else{
							}
											
							### PREPARE DATA FOR PRINTING, PUSH DATA TO ARRAY AND PRINT TO FILE ###
							my $amino_acids_between_mutation_and_ptc_joined = join("-", @amino_acids_between_mutation_and_ptc);
							push @data_array, $transcript_id_value, $sample_id_value, $ensembl_transcript_id, $refseq_transcript_id, $UCSC_transcript_id, $mutation_subtype_value, 
								$mutation_chromosome_value, $mutation_start_value, $mutation_end_value, $mutation_length, $transcript_strand, $mutation_allel_count_value, 
								$wild_type_allel_count_value, $variant_allel_frequency, $corresponding_gene_id, $number_of_fetched_transcripts, $number_of_transcripts_in_corresponding_gene, 
								$number_of_coding_transcripts_in_corresponding_gene, $number_of_transcripts_on_locus, $number_of_coding_transcripts_on_locus, $exon_containing_mutation_id, 
								$exon_number_containing_mutation, $number_exons_in_transcript, $number_of_coding_exons, $first_coding_exon, $last_coding_exon, $number_of_exons_after_mutation, 
								$number_of_coding_exons_after_mutation, $mutation_point_in_exon, $mutation_point_in_cdna, $distance_of_mutation_start_from_previous_splice_site, 
								$distance_of_mutation_start_from_next_splice_site, $distance_of_mutation_start_from_last_splice_site, $distance_of_mutation_start_from_last_coding_splice_site, 
								$distance_of_mutation_start_from_coding_cdna_end, $distance_of_mutation_start_from_cdna_end, $primary_ptc_sequence, $primary_ptc_distance_in_amino_acids, 
								$amino_acids_between_mutation_and_ptc_joined, $primary_ptc_locus_in_cdna, $primary_ptc_exon, $number_of_exon_containing_primary_ptc, $number_of_exons_after_primary_ptc, $number_of_coding_exons_after_primary_ptc, 
								$distance_of_ptc_from_previous_exon_splice_site, $distance_of_ptc_from_next_exon_splice_site, $distance_of_ptc_from_last_exon_splice_site_in_transcript, 
								$distance_of_ptc_from_last_coding_exon_splice_site_in_transcript, $distance_of_ptc_from_transcript_cdna_end, $distance_of_ptc_from_transcript_cdna_coding_end;
							my $data_array_print = join("\t", @data_array);
							print $fh $data_array_print;
							print $fh "\n";
						}else{
						}
					
					}else{
					}
				
					
		}else{
		}	     
          
    }
}

close $fh;

