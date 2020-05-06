//%attributes = {}
  // deploy_jamfPro_precheck_set_XML
  // $vb_goodToGo:=deploy_jamfPro_precheck_set_XML($vt_xmlRootReference;$vt_xpath;$vt_targetServer;$vt_URL)

$vt_xmlRootElementReference:=$1
$vt_xpath:=$2
$vt_targetServer:=$3
$vt_url:=$4
$vt_setName:=$5
$vt_FieldName:=$6
$vt_Push_MergeOrCreateNew:=$7

$vb_goodToGo:=False:C215

$vt_issueDescription:=""

$vt_xmlRef:=DOM Find XML element:C864($vt_xmlRootElementReference;$vt_xpath)
If (OK=0)  // The xml HAS to have this value or Jamf Pro won't take it. 
	$vt_issueDescription:="Couldn't find a required xpath"
Else 
	
	DOM GET XML ELEMENT VALUE:C731($vt_xmlRef;$vt_Value)
	If ($vt_Value="")
		$vt_issueDescription:="I couldn't find a required value"
	Else 
		If ($vt_Push_MergeOrCreateNew#"Create New")
			  // If we're merging, it does not matter if the item already exists
			$vb_goodToGo:=True:C214
		Else 
			  // We are creating new records
			  // Now that we have the value to check, we need to see if it exists in the target Jamf Pro. 
			  // Most uniqueness constraits are implemented because they are used as identifiers for a record. 
			  // They typically have an api endpoint to allow us to find the matching record via API. 
			  // For example, the xpath to the serial number in a computer's XML data is /computer/serialnumber
			  //  and there is an API endpoint called /computers/serialnumber/{serialnumber}.
			  // So we can see if we get a record back when we call that against the target Jamf Pro
			  // If there is, we have a collision
			  // $vt_xpathBase:=substring($vt_xpath;1;position("/";$vt_xpath;2))
			$vt_url:=$vt_targetServer+$vt_url+"/"+sh_http_urlEncode ($vt_Value)
			
			$vt_userPipePass:=Import_GetJamfProServerLogin ($vt_selectedSourceServer)
			If ($vt_userPipePass="")
				sh_msg_Alert ("I couldn't find a username and password for this Jamf Pro. Re-add it using the import server dropdown menu.")
			Else 
				$vl_PipePosition:=Position:C15("|";$vt_userPipePass)
				$vt_API_User_Name:=Substring:C12($vt_userPipePass;1;$vl_PipePosition-1)  // escape double-quotes in passwords? pipes in user?
				$vt_API_Password:=Substring:C12($vt_userPipePass;$vl_PipePosition+1)
				HTTP AUTHENTICATE:C1161($vt_API_User_Name;$vt_API_Password;HTTP basic:K71:8)
				ARRAY TEXT:C222($at_httpHeader_Keys;0)
				ARRAY TEXT:C222($at_httpHeader_Values;0)
				APPEND TO ARRAY:C911($at_httpHeader_Keys;"Accept")
				APPEND TO ARRAY:C911($at_httpHeader_Values;"application/xml")
				$vt_body:=""
				$vt_ApiResponseText:=""
				$vl_httpTimeout:=Num:C11(sh_prefs_getValueForKey ("setting.jamf.capi.http.timeout_seconds";"10"))
				HTTP SET OPTION:C1160(HTTP timeout:K71:10;$vl_httpTimeout)
				ON ERR CALL:C155("sh_err_call")
				vl_Error:=0
				$vl_httpStatusCode:=HTTP Request:C1158(HTTP GET method:K71:1;$vt_URL;$vt_body;$vt_ApiResponseText;$at_httpHeader_Keys;$at_httpHeader_Values)
				ON ERR CALL:C155("")
				If (vl_Error#0)
					sh_msg_Alert ("Error: Could not reach the target Jamf Pro server to check for duplicates. ("+String:C10(vl_Error)+")")
				End if 
				
				Case of 
					: ($vl_httpStatusCode=404)
						  // Good... the thing doesn't exist
						$vb_goodToGo:=True:C214
					: ($vl_httpStatusCode=504)
						sh_msg_Alert ("I got a timeout (504) from the target Jamf Pro server when I was checking for duplicates. Try again?")
					: ($vl_httpStatusCode=200)
						Case of 
							: ($vt_FieldName="name")
								sh_msg_Alert ("I can't upload the "+$vt_setName+" configuration set. The target Jamf Pro already has a "+[XML:2]ItemType:6+" named "+sh_str_dq ($vt_Value)+". Try doing a merge instead?")
							Else 
								sh_msg_Alert ("I can't upload the "+$vt_setName+" configuration set. The target Jamf Pro already has a "+[XML:2]ItemType:6+" with the same "+$vt_FieldName+". ("+sh_str_dq ($vt_Value)+") Try doing a merge instead?")
						End case 
					Else   // bad password? 
						sh_msg_Alert ("I got an error from the target Jamf Pro server when I was checking for duplicates. ("+String:C10($vl_httpStatusCode)+")")
				End case 
				
			End if 
		End if 
	End if 
	
End if 

If ($vt_issueDescription#"")
	$vb_goodToGo:=False:C215
	DOM EXPORT TO VAR:C863($vt_xmlRootElementReference;$vt_xml)
	vt_deployedItemsSummary:=vt_deployedItemsSummary+"[error] "+$vt_issueDescription+" when pre-flighting the XML items."+<>CRLF
	vt_deployedItemsSummary:=vt_deployedItemsSummary+"[Set] "+sh_str_dq ($vt_setName)+<>CRLF
	vt_deployedItemsSummary:=vt_deployedItemsSummary+"[Item] Missing "+$vt_FieldName+" in "+[XML:2]ItemType:6+" "+sh_str_dq ([XML:2]HumanReadableItemName:9)+<>CRLF
	vt_deployedItemsSummary:=vt_deployedItemsSummary+"[XPath] "+$vt_xpath+<>CRLF
	vt_deployedItemsSummary:=vt_deployedItemsSummary+"[info] This item type should have the following required values:"+<>CRLF
	vt_deployedItemsSummary:=vt_deployedItemsSummary+[Endpoints:7]XML_UniquenessConstraint_Xpaths:17+<>CRLF
	vt_deployedItemsSummary:=vt_deployedItemsSummary+"------------ XML ------------"+<>CRLF
	vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_xml+<>CRLF
	vt_deployedItemsSummary:=vt_deployedItemsSummary+"---------- END XML ----------"+<>CRLF
	sh_msg_Alert ("I found an issue with an item you are trying to deploy. Please see the transcript for more details.")
End if 

$0:=$vb_goodToGo