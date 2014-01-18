#!/usr/bin/env Rscript

library(sqldf)

sqlcommand<-("")

#sianttm
select tax2rank.taxid, name, rank from tax2rank join taxid2name on tax2rank.taxid = taxid2name.taxid limit 5;

create table graphinputnodes as select tax2rank.taxid, name, rank from tax2rank join taxid2name on tax2rank.taxid = taxid2name.taxid;

#add a counter
create table nodes (cnt integer primary key autoincrement, taxid integer, name nvarchar, rank nvarchar);
insert into nodes(taxid, name, rank) select * from graphinputnodes;

#cnt     taxid   name    rank
#1       1       root    no rank
#2       2       Bacteria        superkingdom
#3       6       Azorhizobium    genus
#4       7       Azorhizobium caulinodans        species
#5       9       Buchnera aphidicola     species
