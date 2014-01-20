#!/usr/bin/env python

from neo4jrestclient.client import GraphDatabase
from neo4jrestclient.constants import RAW

gdb = GraphDataBase("http://localhost:7474/db/data/")

q = "START n=node:ncbitaxid(taxid={taxidparam}) return n"
params = {2}
gdb.query(q, params=params, returns 

