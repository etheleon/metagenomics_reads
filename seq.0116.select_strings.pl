#!/usr/bin/env perl 

########################################
#Initialise
########################################

#--Set outer output directory
$directory='out/seq.0116'; unless(-e $directory or mkdir $directory) {die "Unable to create $directory\n";}

#--Read KO specific refsearch files 
##--loop through on ur own.
#@files=`ls out/seq.0113.v2/`; #-- each sequencing lane
#foreach $seqlane (@files){ 

$seqlane=$ARGV[0];
    $seqlane=~s/\n//g;
#--Set inner output directory
    $outputdir="$directory".'/'."$seqlane"; unless(-e $outputdir or mkdir $outputdir) {die "Unable to create $outputdir\n";} #-- creates output directory ie. out/seq.0116/b1-0057_s_1
	$innerdir='out/seq.0113.v2/'."$seqlane";
	@kos=`ls $innerdir`;  #-- each KO

########################################
#Extraction
########################################
#Foreach ko X sequencing lane
	foreach $ko (@kos) { 
	    $ko=~s/\n//g;

#-- Step1: Read in bitscores for KXXXXX in sequencing lane X
	    @bitscore=();
	    open (INPUT1, "$innerdir".'/'."$ko") || die $!;
	    while(<INPUT1>) { 
    		chomp;
    		m/(\S+)$/;		#the bitscore
		    push(@bitscore, $1);
	    }
#-- Step2: Calculate threshold > 0.8 of top bitscore
	    @bitscore = sort { $b <=> $a } @bitscore; #sorts the array
		$threshold=$bitscore[0] * 0.8;	#threshold
#	print $ko,"\t",$threshold,"\n";

##-- Step3: Print only reads above the threshold 
		seek INPUT1, 0, 0;		#goback to the top 
    		open(OUTPUT, ">$outputdir".'/'."$ko") || die $!;
	    while(<INPUT1>) { 			#going through again to extract those above threshold
    		/(\S+)$/;	
    		print OUTPUT $ko,"\t",$_ if $1 >= $threshold ;
	    }
    	    close(OUTPUT);
	    close(INPUT1);
	}
#	}
