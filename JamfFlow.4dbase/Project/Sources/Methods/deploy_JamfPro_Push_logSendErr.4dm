//%attributes = {}
  //deploy_JamfPro_Push_logSendErr 
  //deploy_JamfPro_Push_logSendErr($vl_httpStatusCode;$vt_httpErrorExplanation;$vt_postOrPutRestMethod;$vt_URL;$vt_apiResponse;$vt_xml)

$vl_httpStatusCode:=$1
$vt_httpErrorExplanation:=$2
$vt_postOrPutRestMethod:=$3
$vt_URL:=$4
$vt_apiResponse:=$5
$vt_xml:=$6

vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+<>CRLF
vt_deployedItemsSummary:=vt_deployedItemsSummary+"[error] The API returned a \""+String:C10($vl_httpStatusCode)+"\" error when we tried to add this item."+<>CRLF
vt_deployedItemsSummary:=vt_deployedItemsSummary+"[info] "+$vt_httpErrorExplanation
vt_deployedItemsSummary:=vt_deployedItemsSummary+"[operation] "+$vt_postOrPutRestMethod+" to "+$vt_URL+<>CRLF

$vt_apiMessage:=sh_html_stripTags ($vt_apiResponse)
vt_deployedItemsSummary:=vt_deployedItemsSummary+"[API message] "+$vt_apiMessage+<>CRLF
Case of 
	: ($vt_apiMessage="Conflict Error: Problem with display_fields")
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"This occurs when the list of display fields includes extension attributes that don't exist on the target Jamf Pro"+<>CRLF
End case 

  // Dump the XML to the log so user can see what's wrong
vt_deployedItemsSummary:=vt_deployedItemsSummary+"------------ XML ------------"+<>CRLF
  // The icon data in the app record and self service can be long and makes the xml hard to read. Remove for easier troubleshooting
  // Related concern... .ipa can also be there. That could exceed the 32K text limit in the message body. Might be able to send it as a blob.
ARRAY TEXT:C222($at_longDataTruncationList;0)
Case of 
	: ([XML:2]ItemType:6="Mac application")
		APPEND TO ARRAY:C911($at_longDataTruncationList;"data")
		APPEND TO ARRAY:C911($at_longDataTruncationList;"description")
	: ([XML:2]ItemType:6="Mobile device application")
		APPEND TO ARRAY:C911($at_longDataTruncationList;"data")
		APPEND TO ARRAY:C911($at_longDataTruncationList;"description")
		APPEND TO ARRAY:C911($at_longDataTruncationList;"self_service_description")
End case 
For ($vl_iterateTruncations;1;Size of array:C274($at_longDataTruncationList))
	$vl_pos_found:=0
	$vl_length_found:=0
	$vt_longDataTruncationValue:=$at_longDataTruncationList{$vl_iterateTruncations}
	$vt_pattern:="<"+$vt_longDataTruncationValue+">[^<]+<\\/"+$vt_longDataTruncationValue+">"
	$vl_startSearchingAtPostion:=1
	While (Match regex:C1019($vt_pattern;$vt_xml;$vl_startSearchingAtPostion;$vl_pos_found;$vl_length_found))
		$vt_xml:=Delete string:C232($vt_xml;$vl_pos_found;$vl_length_found)
		$vt_newTag:=$vt_longDataTruncationValue+"-removed"
		$vt_xml:=Insert string:C231($vt_xml;"<"+$vt_newTag+">removed for log readability</"+$vt_newTag+">";$vl_pos_found)
	End while 
End for 
$vt_xml:=Replace string:C233($vt_xml;"\r";"\n")  // Mac-format line endings
vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_xml+<>CRLF