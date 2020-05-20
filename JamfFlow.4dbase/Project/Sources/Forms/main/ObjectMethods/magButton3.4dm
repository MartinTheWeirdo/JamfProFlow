$vsDocName:=Temporary folder:C486+"JamfFlowScrapbook"+String:C10(1+(Random:C100%99))+".txt"
TEXT TO DOCUMENT:C1237($vsDocName;vt_selectedItemsSummary;"UTF-8";Document with LF:K24:22)
OPEN URL:C673($vsDocName)
