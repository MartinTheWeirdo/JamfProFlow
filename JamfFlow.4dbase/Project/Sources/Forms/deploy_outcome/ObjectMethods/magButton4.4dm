$vt:=""
For ($i;1;Size of array:C274(at_deployed_Set))
	$vt:=$vt+sh_str_dq (at_deployed_Set{$i})+","
	$vt:=$vt+sh_str_dq (at_deployed_ItemType{$i})+","
	$vt:=$vt+sh_str_dq (at_deployed_ItemName{$i})+","
	$vt:=$vt+sh_str_dq (at_deployed_AddedOrUpdated{$i})+","
	$vt:=$vt+sh_str_dq (at_deployed_Status{$i})+","
	$vt:=$vt+sh_str_dq (at_deployed_Note{$i})+<>CRLF
End for 

$vsDocName:=Temporary folder:C486+"JamfFlow_upload_report_"+String:C10(1+(Random:C100%99))+".csv"
TEXT TO DOCUMENT:C1237($vsDocName;$vt;"UTF-8";Document with LF:K24:22)
OPEN URL:C673($vsDocName)
