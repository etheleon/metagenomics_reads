
#things to write into sqlite console 
CREATE TABLE taxid (gi INTEGER primary key, taxid INTEGER);
.separator "\t"

import taxonomy/ftp.ncbi.nlm.nih.gov/pub/taxonomy/gi_taxid_nucl.dmp taxid


