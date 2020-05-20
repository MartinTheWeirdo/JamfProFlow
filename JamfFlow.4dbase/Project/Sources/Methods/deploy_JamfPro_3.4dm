//%attributes = {}
$vt_Push_MergeOrCreateNew:=$1
$vt_targetServer:=$2
$vt_API_User_Name:=$3
$vt_API_Password:=$4
$vt_onErrorAction:=$5
$vl_xmlIterator:=$6
$vl_NumberOfItemsToSave:=$7
$vb_AddDateTimeToName:=$8
$vt_dateTimeStamp:=$9


$vb_goodToGo:=True:C214  // Assume success
$vt_postOrPutRestMethod:=""
$vt_deployed_Note:="Unknown Error"

  //
  // Prep the XML for upload
  //
$o_return:=deploy_JamfPro_3a_prepXML ([XML:2]XML:2;$vb_AddDateTimeToName;$vt_dateTimeStamp;$vt_Push_MergeOrCreateNew)
$vt_xml:=$o_return.$vt_xml
$vb_goodToGo:=$o_return.$vb_goodToGo
$vt_deployed_Note:=$o_return.$vt_deployed_Note
$vt_errorMessage:=$o_return.$vt_errorMessage
CLEAR VARIABLE:C89($o_return)

$vb_goodToGo:=($vt_xml#"")

If (Not:C34($vb_goodToGo))
	  //TRACE
End if 

$vb_processThisItem:=True:C214


  // Write the xml to target server

  // To do... adjust the priorities as needed. 
  // If an item has a missing dependency, it will fail. 
  // We can look for dependencies and check each. If they are not on the target or in set, we error.
  // If they are in set but not yet in target, push set into a 4D "to-do" set. 

  // The endpoint will depend on merge or create new option. 
  // If Create new, we have already checked for name collisions. We will POST to id=0
  // If merge, check if the item already exists. If it does, PUT to the item's ID on target, else POST new. 
If ($vb_goodToGo)
	  // Calculate the http method (post or put) and the API URL
	Case of 
		: ($vt_Push_MergeOrCreateNew="Create New")
			$vt_postOrPutRestMethod:=HTTP POST method:K71:2
			$vt_URL:=api_get_urlToItemByID ($vt_targetServer+[Endpoints:7]API_URL_to_lookup_by_id:23;"0")
			$vb_processThisItem:=(Not:C34([Endpoints:7]Has_Method_Post:13))  // If it doesn't support post, we have to skip it
			
		: ($vt_Push_MergeOrCreateNew="Merge")
			C_OBJECT:C1216($o_resultsObject)
			$o_resultsObject:=deploy_JamfPro_3c ($vt_targetServer;$vt_API_User_Name;$vt_API_Password)
			$vb_goodToGo:=$o_resultsObject.$vb_goodToGo
			$vt_postOrPutRestMethod:=$o_resultsObject.$vt_postOrPutRestMethod
			$vt_deployed_Note:=$o_resultsObject.$vt_deployed_Note
			  //$vt_jssRecordSpecifier:=$o_resultsObject.$vt_jssRecordSpecifier
			$vt_URL:=$o_resultsObject.$vt_URL
			CLEAR VARIABLE:C89($o_resultsObject)
			Case of 
				: ($vt_postOrPutRestMethod=HTTP POST method:K71:2)
					$vb_processThisItem:=([Endpoints:7]Has_Method_Post:13)  // If it doesn't support post, we have to skip it
				: ($vt_postOrPutRestMethod=HTTP PUT method:K71:6)
					$vb_processThisItem:=([Endpoints:7]Has_Method_Put:14)  // If it doesn't support put, we have to skip it
			End case 
	End case 
End if   // If ((Not($vb_processThisItem)) & ($vb_goodToGo))


If ($vb_goodToGo & $vb_processThisItem)
	  // Now we can push the new XML info
	HTTP AUTHENTICATE:C1161($vt_API_User_Name;$vt_API_Password;HTTP basic:K71:8)
	ARRAY TEXT:C222(at_httpHeader_Keys;0)
	ARRAY TEXT:C222(at_httpHeader_Values;0)
	APPEND TO ARRAY:C911(at_httpHeader_Keys;"Accept")
	APPEND TO ARRAY:C911(at_httpHeader_Values;"application/xml")
	$vt_apiResponse:=""
	$vl_httpTimeout:=Num:C11(sh_prefs_getValueForKey ("setting.jamf.capi.http.timeout_seconds";"10"))
	HTTP SET OPTION:C1160(HTTP timeout:K71:10;$vl_httpTimeout)
	ON ERR CALL:C155("sh_err_call")
	vl_Error:=0
	$vl_httpStatusCode:=0
	$vl_httpStatusCode:=HTTP Request:C1158($vt_postOrPutRestMethod;$vt_URL;$vt_xml;$vt_apiResponse;at_httpHeader_Keys;at_httpHeader_Values)
	ON ERR CALL:C155("")
	If (vl_Error#0)
		$vb_goodToGo:=False:C215
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"[error] Network problem when sending data to the target Jamf Pro Server. ("+String:C10(vl_Error)+")"+<>CRLF
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"[URL] "+$vt_postOrPutRestMethod+" to "+$vt_URL+<>CRLF
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"------------ XML ------------"+<>CRLF
		vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_xml+<>CRLF
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"---------- END XML ----------"+<>CRLF
		sh_msg_Alert ("There was a network error sending data to Jamf Pro")
		$vt_deployed_Note:="Network error sending record"
	End if 
End if 


If ($vb_goodToGo)  // Item processed without error
	
	If ($vb_processThisItem)
		
		$vt_httpErrorExplanation:=""  // If there is a problem we'll populate this and print an explanation
		
		If (($vl_httpStatusCode=201) | ($vl_httpStatusCode=200))
			
			
			Case of 
				: ($vl_httpStatusCode=201)
					  // Request to create or update object successful
					  //$vt_apiResponse == "<?xml version="1.0" encoding="UTF-8"?><policy><id>5</id></policy>"
					If ([Endpoints:7]isSingleton:16)
						$vt_newlyCreatedItemID_msg:=""
						$vt_newlyCreatedItemID:=""
					Else 
						  // Get the jss record id from the response xml
						$vt_pattern:="<id>[^<]+<\\/id>"
						$vl_startSearchingAtPostion:=1
						C_LONGINT:C283($vl_pos_found)
						C_LONGINT:C283($vl_length_found)
						$vb_idTagFound:=Match regex:C1019($vt_pattern;$vt_apiResponse;$vl_startSearchingAtPostion;$vl_pos_found;$vl_length_found)
						If ($vb_idTagFound)
							$vt_newlyCreatedItemID:=Substring:C12($vt_apiResponse;$vl_pos_found+4;$vl_length_found-9)
							$vt_newlyCreatedItemID_msg:=" (ID="+$vt_newlyCreatedItemID+")"
						Else 
							$vt_newlyCreatedItemID_msg:=""
						End if 
					End if 
					If ($vt_postOrPutRestMethod=HTTP POST method:K71:2)
						vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"  -> [OK] Item created on target."+$vt_newlyCreatedItemID_msg+" (201)"+<>CRLF
						$vt_deployed_Note:="✅ Item created "+$vt_newlyCreatedItemID_msg
					Else 
						vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"  -> [OK] Item updated on target."+$vt_newlyCreatedItemID_msg+" (201)"+<>CRLF
						$vt_deployed_Note:="✅ Item updated "+$vt_newlyCreatedItemID_msg
					End if 
					
					
					  // For the artifact display box on the deploy tab
					$vt_Artifact_Name:=[XML:2]ItemType:6+" "+[XML:2]HumanReadableItemName:9
					$vt_Artifact_Link:=Replace string:C233($vt_targetServer+[Endpoints:7]Detail_Web_Page:4;"{id}";$vt_newlyCreatedItemID)
					APPEND TO ARRAY:C911(at_DeployLinks_Names;$vt_Artifact_Name)
					APPEND TO ARRAY:C911(at_DeployLinks_Links;$vt_Artifact_Link)
					
					
				: ($vl_httpStatusCode=200)
					vt_deployedItemsSummary:=vt_deployedItemsSummary+" -> [OK] Item sent (HTTP-200)"+<>CRLF
					$vt_deployed_Note:="Sent OK (200)"
					  // this is good. It's what we get when we post a new record. 
					  // This would be a good place to parse out the new jss ID and add a note to the lot info field. 
			End case 
		Else   //not (($vl_httpStatusCode=201)|($vl_httpStatusCode=200))
			
			$vt_apiMessage:=sh_html_stripTags ($vt_apiResponse)
			Case of 
				: ($vl_httpStatusCode=409)
					  // Conflicts happen when you try to post something that already exists. Check the lookup url in [endpoints] -- you did it wrong...
					  // Or when there's a reference to a non-existant object. 
					  // Or when you're missing a required value (SMTP Server Password)
					Case of 
						: ($vt_apiMessage="Conflict Error: Problem with criteria")
							$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"Do the criteria reference an extension attribute or another group that does not yet exist on the target server?"+<>CRLF
							$vt_deployed_Note:=$vt_apiMessage
						: ($vt_apiMessage="@Password is required for authentication.")
							$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"This object type requires a password value and the XML doesn't have one. "+<>CRLF
							$vt_deployed_Note:="XML is missing required password attribute"
						Else 
							$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"This usually happens when the XML contains a reference to some "+<>CRLF
							$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"other object (e.g. a site) that doesn't exist on the target Jamf "+<>CRLF
							$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"Pro or when the API is enforcing some other validity check."+<>CRLF
							$vt_deployed_Note:=$vt_apiMessage  // +" [409] (Conflicting or missing data)"
					End case 
					
				: ($vl_httpStatusCode=401)
					$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"This usually means we have a bad username and/or password, or your API"+<>CRLF
					$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"username doesn't have write permission. Make sure you've selected the"+<>CRLF
					$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"intended target Jamf Pro from the dropdown menu."+<>CRLF
					If (Current user:C182="Designer")
						$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"[debug][user] "+sh_str_dq ($vt_API_User_Name)+<>CRLF
						$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"[debug][pass] "+sh_str_dq ($vt_API_Password)+<>CRLF
					End if 
					$vt_deployed_Note:="API authentication or write permissions error (401)"
					
				: ($vl_httpStatusCode=404)
					  // You tried to PUT to something that does not already exist. Check the lookup url and unique field info in [endpoints]
					$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"This usually occurs becaue we tried to update an item that does not exist in the target Jamf Pro "+<>CRLF
					$vt_deployed_Note:="Bad URL (404)"
				Else 
					  // This is bad
					$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"Unexpected response. "+String:C10($vl_httpStatusCode)+<>CRLF
					$vt_deployed_Note:="Unknown errror: "+String:C10($vl_httpStatusCode)
			End case   // if($vl_httpStatusCode=201)
			
			  // Handle errors
			If ($vt_httpErrorExplanation#"")  // Was there an error? 
				$vb_goodToGo:=False:C215
				deploy_JamfPro_Push_logSendErr ($vl_httpStatusCode;$vt_httpErrorExplanation;$vt_postOrPutRestMethod;$vt_URL;$vt_apiResponse;$vt_xml)
				  // sh_msg_Alert ("There was a problem writing an item to Jamf Pro. Please see the transcript for more information.")
			End if 
		End if   //If (($vl_httpStatusCode=201)|($vl_httpStatusCode=200))
		
	Else   // If ($vb_processThisItem)
		  // Skipped item
		vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"  -> [SKIP] The item was not uploaded."+<>CRLF
		$vt_deployed_Note:="⚠️-Could not process"
	End if 
	
Else 
	$vt_deployed_Note:="🚫 "+$vt_deployed_Note
End if 



If (Not:C34($vb_goodToGo))  // There was an error processing the item
	If ($vt_onErrorAction="Ask")
		If (($vl_xmlIterator=$vl_NumberOfItemsToSave) & (Records in set:C195("$ab_DeploySetsHighlightedSet")=1))
			  // We are the last xml and there was only one set selected. There's no point in asking them if they want to continue.
			$vt_onErrorAction:="Skip"
		Else 
			  // Lets see what they want to do on a failure... stop or keep going and run out
			  // and risk that some downstream items will fail based on a missing dependency
			$vt_message:=""
			$vt_message:=$vt_message+"I encountered an issue when processing the "+[Endpoints:7]Human_Readable_Singular_Name:3+" "
			$vt_message:=$vt_message+sh_str_dq ([XML:2]HumanReadableItemName:9)+"."+<>CRLF+sh_str_dq ($vt_deployed_Note)+<>CRLF+<>CRLF
			$vt_message:=$vt_message+"Do you want me to try the remaining items?"
			$vb_skipErrorsSelected:=sh_msg_Alert ($vt_message;"Keep going";"Stop")
			If ($vb_skipErrorsSelected)
				$vt_onErrorAction:="Skip"
			Else 
				$vt_onErrorAction:="Stop"
			End if 
		End if 
	End if 
End if 


C_OBJECT:C1216($o_return)
$0:=New object:C1471("$vb_goodToGo";$vb_goodToGo;"$vt_postOrPutRestMethod";$vt_postOrPutRestMethod;"$vt_deployed_Note";$vt_deployed_Note;"$vt_onErrorAction";$vt_onErrorAction;"$vb_processThisItem";$vb_processThisItem)

