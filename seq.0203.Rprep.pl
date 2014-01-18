#!/usr/bin/env perl 

use strict;
$,="\t";
while(<>) { 
if($.==4) { 	
   my @taxonnames=split("\t",$_); 
   shift @taxonnames;
   print @taxonnames;
}else{print if m/^\S+\s[0|1]+$/;}}
