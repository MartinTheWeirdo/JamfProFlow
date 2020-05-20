//%attributes = {}
  // deploy_JamfPro_3c
  // $o_resultsObject:=deploy_JamfPro_3c ($vt_targetServer;$vt_API_User_Name;$vt_API_Password)

$vt_targetServer:=$1
$vt_API_User_Name:=$2
$vt_API_Password:=$3

$vb_goodToGo:=True:C214

Case of 
	: ([Endpoints:7]isSingleton:16)
		$vt_postOrPutRestMethod:=HTTP PUT method:K71:6
		  //$vt_jssRecordSpecifier:="singleton"
		  // ../JSSResource/activationcode
		$vt_deployed_Note:=""
		$vt_URL:=$vt_targetServer+[Endpoints:7]API_URL_to_lookup_by_Name:21
	Else 
		  // We need to find out if the record already exists so we can tell if we need to post or put.
		  // If we are updating an existing record on the target system, we'll need to look it up by name 
		  //  in order to obtain the record ID needed to compose the API URL.  
		$vt_URL:=api_get_urlToUniqueNameItem ($vt_targetServer+[Endpoints:7]API_URL_to_lookup_by_Name:21;[XML:2]API_Unique_Item_Name:3)
		HTTP AUTHENTICATE:C1161($vt_API_User_Name;$vt_API_Password;HTTP basic:K71:8)
		$vt_apiResponse:=""
		ARRAY TEXT:C222(at_httpHeader_Keys;0)
		ARRAY TEXT:C222(at_httpHeader_Values;0)
		APPEND TO ARRAY:C911(at_httpHeader_Keys;"Accept")
		APPEND TO ARRAY:C911(at_httpHeader_Values;"application/xml")
		$vt_data:=""  // There is no input data on a get
		$vl_httpTimeout:=Num:C11(sh_prefs_getValueForKey ("setting.jamf.capi.http.timeout_seconds";"10"))
		HTTP SET OPTION:C1160(HTTP timeout:K71:10;$vl_httpTimeout)
		vl_Error:=0
		ON ERR CALL:C155("sh_err_call")
		$vl_httpStatusCode:=HTTP Request:C1158(HTTP GET method:K71:1;$vt_URL;$vt_data;$vt_apiResponse;at_httpHeader_Keys;at_httpHeader_Values)
		ON ERR CALL:C155("")
		If (vl_Error#0)
			vt_deployedItemsSummary:=vt_deployedItemsSummary+" -> [error] Network error trying to check if there was a Jamf Pro record for "+$vt_URL+<>CRLF
			sh_msg_Alert ("Sorry, there was a network error. Please see the transcript for more details.")
			$vb_goodToGo:=False:C215
			$vt_deployed_Note:="HTTP error looking up record number"
		End if 
		
		If ($vb_goodToGo)
			$vt_httpErrorDescription:=""
			Case of 
				: ($vl_httpStatusCode=200)
					  // It already exists
					$vt_postOrPutRestMethod:=HTTP PUT method:K71:6
					  // Although we were able to look up the record by name, you can't always use that endpoint format 
					  // for POST or PUT... at least not according to the documentation. In some cases you have to do that by ID. 
					  // Parse the XML from the target server and grab the item's JSS ID
					vl_error:=0
					ON ERR CALL:C155("sh_err_call")
					$vt_xmlRootElementReference:=DOM Parse XML variable:C720($vt_apiResponse)
					  //DOM EXPORT TO VAR($vt_xmlRootElementReference;$t)
					ON ERR CALL:C155("")
					If (vl_error#0)  // Could not parse the xml response
						$vt_httpErrorDescription:="I could not parse the API response XML."
						$vt_deployed_Note:="XML Parse error looking up record ID"
					Else 
						  // We have the item's detail XML after GETting by name
						$vt_xpathToIDElement:=[Endpoints:7]Detail_XML_ID_Element_xpath:31
						$vt_xmlRefItemID:=DOM Find XML element:C864($vt_xmlRootElementReference;$vt_xpathToIDElement)
						If ($vt_xmlRefItemID="00000000000000000000000000000000")
							$vt_httpErrorDescription:=$vt_httpErrorDescription+"[error] I couldn't locate the item's ID number when checking it's XML data from the target server."+<>CRLF
							$vt_httpErrorDescription:=$vt_httpErrorDescription+"[xpath] Expected "+sh_str_dq ($vt_xpathToIDElement)+<>CRLF
							$vt_deployed_Note:="XML Parse error looking up record ID"
						Else 
							$vt_ItemID:=""
							DOM GET XML ELEMENT VALUE:C731($vt_xmlRefItemID;$vt_ItemID)
							If ($vt_ItemID="")
								$vt_httpErrorDescription:=$vt_httpErrorDescription+"[error] I couldn't find a value for the item's ID number when checking it's XML data from the target server."+<>CRLF
								$vt_deployed_Note:="XML Parse error looking up record ID"
							Else 
								$vt_URL:=api_get_urlToItemByID ($vt_targetServer+[Endpoints:7]API_URL_to_lookup_by_id:23;$vt_ItemID)
							End if 
						End if 
						If ($vt_xmlRootElementReference#"00000000000000000000000000000000")
							DOM CLOSE XML:C722($vt_xmlRootElementReference)
						End if 
					End if 
				: ($vl_httpStatusCode=404)
					  // It doesn't exist on the target. POST a new record. We can just use /id/0 for this. 
					$vt_postOrPutRestMethod:=HTTP POST method:K71:2
					$vt_URL:=api_get_urlToItemByID ($vt_targetServer+[Endpoints:7]API_URL_to_lookup_by_id:23;"0")
				: ($vl_httpStatusCode=401)
					  // auth error
					$vt_httpErrorDescription:=$vt_httpErrorDescription+" -> HTTP 401 error. Bad username and/or password, or user does not have the right permissions."+<>CRLF
					$vt_deployed_Note:="API auth error looking up record ID"
					If (Current user:C182="Designer")
						$vt_httpErrorDescription:=$vt_httpErrorDescription+"[debug][user] "+sh_str_dq ($vt_API_User_Name)+<>CRLF
						$vt_httpErrorDescription:=$vt_httpErrorDescription+"[debug][pass] "+sh_str_dq ($vt_API_Password)+<>CRLF
					End if 
					
				Else 
					  // Unexpected. Server could be busy? 
					$vt_httpErrorDescription:=$vt_httpErrorDescription+" -> Unexpected "+String:C10($vl_httpStatusCode)+" HTTP response code"+<>CRLF
					$vt_deployed_Note:="Unknown HTTP status looking up record ID"
			End case 
			
			If ($vt_httpErrorDescription#"")
				$vb_goodToGo:=False:C215
				vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF
				vt_deployedItemsSummary:=vt_deployedItemsSummary+"[error] Bad API result when checking for existing object on the target"+<>CRLF
				vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_httpErrorDescription
				vt_deployedItemsSummary:=vt_deployedItemsSummary+"[URL] "+$vt_URL+<>CRLF
				vt_deployedItemsSummary:=vt_deployedItemsSummary+"------------ API Response ------------"+<>CRLF
				vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_apiResponse+<>CRLF
				vt_deployedItemsSummary:=vt_deployedItemsSummary+"---------- END API Response ----------"+<>CRLF
				  // sh_msg_Alert ("There was a problem when checking for existing target items. Please see the transcript for details.")
			End if 
			
		End if   //If (vl_Error#0)
End case   // If ([Endpoints]isSingleton)

C_OBJECT:C1216($0)
  //$0:=New object("$vb_goodToGo";$vb_goodToGo;"$vt_postOrPutRestMethod";$vt_postOrPutRestMethod;"$vt_jssRecordSpecifier";$vt_jssRecordSpecifier;"$vt_URL";$vt_URL)

$0:=New object:C1471("$vb_goodToGo";$vb_goodToGo;"$vt_postOrPutRestMethod";$vt_postOrPutRestMethod;"$vt_URL";$vt_URL;"$vt_deployed_Note";$vt_deployed_Note)
