//%attributes = {}
  // deploy_JamfPro_Push_

$vt_targetServer:=$1
$vt_Push_MergeOrCreateNew:=$2
$vb_ScopeRemovalRequested:=$3
$vb_AddDateTimeToName:=$4
$vt_dateTimeStamp:=$5
$vt_API_User_Name:=$6
$vt_API_Password:=$7

C_TEXT:C284($vt_targetServer;$1;$vt_Push_MergeOrCreateNew;$2;$vt_dateTimeStamp;$5;$vt_API_User_Name;$6;$vt_API_Password;$7)
C_BOOLEAN:C305($vb_ScopeRemovalRequested;$3;$vb_AddDateTimeToName;$4)

  // We'll flip this if the user presses the stop button in the progress bar
$vb_UserInteruptedProcess:=False:C215

$vl_progressProcessRef:=Progress_New ("Uploading Configuration Set";900;500)

  // To keep a list of what worked and what did not that we can display when done...
ARRAY TEXT:C222(at_deployed_Set;0)
ARRAY TEXT:C222(at_deployed_ItemType;0)
ARRAY TEXT:C222(at_deployed_ItemName;0)
ARRAY TEXT:C222(at_deployed_AddedOrUpdated;0)
ARRAY TEXT:C222(at_deployed_Outcome;0)
ARRAY TEXT:C222(at_deployed_Note;0)
ARRAY LONGINT:C221(al_deploy_rowColors;0)
$vl_TotalSetCount:=0
$vl_TotalItemCount:=0
$vl_TotalItemCount_ok:=0
$vl_TotalItemCount_skip:=0
$vl_TotalItemCount_fail:=0


FIRST RECORD:C50([Sets:1])
For ($vl_pushListIterator;1;Records in selection:C76([Sets:1]))  // Loop throught the list of sets
	
	If (Is in set:C273("$ab_DeploySetsHighlightedSet"))
		
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"======================================================="+<>CRLF
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"Starting upload of configuration set "+[Sets:1]Name:2+<>CRLF
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"======================================================="+<>CRLF
		
		$vl_TotalSetCount:=$vl_TotalSetCount+1
		
		  // Load the XML records for this set
		QUERY:C277([XML:2];[XML:2]set_id:4=[Sets:1]ID:1)
		  // Put the xml records in order so dependencies come first
		  // This sometimes does not run. 
		  // If you look at endpoints in debug, there is one selected record, but the fields are all blank. 
		  // Like it thinks you are in the middle of creating a record. 
		  // Cx unknown. Restarting fixes it and the sort starts working again. 
		  //UNLOAD RECORD([Endpoints])
		ORDER BY:C49([XML:2];[Endpoints:7]push priority:20;>;[Endpoints:7]API_Endpoint_Name:8;>)
		
		
		$vl_NumberOfItemsToSave:=Records in selection:C76([XML:2])
		
		For ($vl_xmlIterator;1;$vl_NumberOfItemsToSave)  // Loop through the xml records for the current set
			
			$vb_itemProcessedOK:=True:C214  // Assume success
			$vt_postOrPutRestMethod:=""
			$vt_deployed_Note:="Unknown Error"
			
			QUERY:C277([Endpoints:7];[Endpoints:7]Human_Readable_Singular_Name:3=[XML:2]ItemType:6)
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"• Sending "+[Endpoints:7]Human_Readable_Singular_Name:3+": "+[XML:2]HumanReadableItemName:9
			
			Progress SET PROGRESS ($vl_progressProcessRef;$vl_xmlIterator/$vl_NumberOfItemsToSave;"Uploading "+[Endpoints:7]Human_Readable_Singular_Name:3+": "+[XML:2]HumanReadableItemName:9;False:C215)
			
			  // Check to see if there are any reasons why we might need to manipulate the XML before we send it to the target
			$vb_ScopeRemovalNeeded:=(([Endpoints:7]detail_xml_scoping_xpath:7#"") & $vb_ScopeRemovalRequested)  // Do we need to remove scope? 
			$vb_DevicePruningNeeded:=(vl_DeployPruneDeviceDetails=1) | (vl_DeployPruneDeviceUser=1)
			$vb_ExtraPruningNeeded:=([Endpoints:7]DeployJamfProPruningXpaths:24#"")
			$vb_ExtraPruningNeeded:=$vb_ExtraPruningNeeded | ([XML:2]ItemType:6="Computer")  // For computers, we need to prune /computer/general/remote_management/management_password_sha256
			$vb_ExtraPruningNeeded:=$vb_ExtraPruningNeeded | ([XML:2]ItemType:6="@ Group")  // For smart computer groups, we need to prune the member info -- the target should calculate that for itself
			
			$vt_xml:=[XML:2]XML:2
			
			If ($vb_AddDateTimeToName | $vb_ScopeRemovalNeeded | $vb_ExtraPruningNeeded | $vb_DevicePruningNeeded)
				  // If any of these are true, we'll need to mess with the xml in some way
				$vt_xml:=deploy_JamfPro_Push_prune ($vt_xml;$vb_AddDateTimeToName;$vb_ScopeRemovalNeeded;$vb_DevicePruningNeeded;$vt_dateTimeStamp;$vt_Push_MergeOrCreateNew)
				$vb_itemProcessedOK:=($vt_xml#"")
				If (Not:C34($vb_itemProcessedOK))
					$vt_deployed_Note:="Pruning error"
				End if 
			End if   // If ($vb_AddDateTimeToName | $vb_ScopeRemovalNeeded)
			
			If ($vb_itemProcessedOK)
				  // Now that we're back to our XML in text, use a regex to remove any id tags. 
				  // If we upload id tags for things like the packages used by a policy, 
				  // JP will look to see if that package exists. If it does not, it will throw a 409 error. 
				  // So we'll strip the ID tags, leaving the name tags behind. 
				  // As long as the name exists, it won't matter that the ID for the 
				  //  package is different on source and target servers. 
				$vl_pos_found:=0
				$vl_length_found:=0
				$vt_pattern:="<id>[^<]+<\\/id>"
				$vl_startSearchingAtPostion:=1
				While (Match regex:C1019($vt_pattern;$vt_xml;$vl_startSearchingAtPostion;$vl_pos_found;$vl_length_found))
					$vt_xml:=Delete string:C232($vt_xml;$vl_pos_found;$vl_length_found)
				End while 
			End if 
			
			  // Write the xml to target server
			
			  // To do... adjust the priorities as needed. 
			  // If an item has a missing dependency, it will fail. 
			  // We can look for dependencies and check each. If they are not on the target or in set, we error.
			  // If they are in set but not yet in target, push set into a 4D "to-do" set. 
			
			  // The endpoint will depend on merge or create new option. 
			  // If Create new, we have already checked for name collisions. We will POST to id=0
			  // If merge, check if the item already exists. If it does, PUT to the item's ID on target, else POST new. 
			If ($vb_itemProcessedOK)
				
				$vb_skipThisItem:=False:C215
				
				  // Calculate post or put / jss record id
				Case of 
					: ($vt_Push_MergeOrCreateNew="Create New")
						$vt_postOrPutRestMethod:=HTTP POST method:K71:2
						$vt_URL:=api_get_urlToItemByID ($vt_targetServer+[Endpoints:7]API_URL_to_lookup_by_id:23;"0")
						
					: ($vt_Push_MergeOrCreateNew="Merge")
						Case of 
							: ([Endpoints:7]isSingleton:16)
								$vt_postOrPutRestMethod:=HTTP PUT method:K71:6
								$vt_jssRecordSpecifier:="singleton"
								  // ../JSSResource/activationcode
								$vt_URL:=$vt_targetServer+[Endpoints:7]API_URL_to_lookup_by_Name:21
								
								
							: ([Endpoints:7]API_Endpoint_Name:8="vppaccounts")
								$vb_skipThisItem:=True:C214
								vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"[skip] Skipping VPP account. These should be entered by hand to protect against license contention between two instances."+<>CRLF+<>CRLF
								
							: ([Endpoints:7]API_Endpoint_Name:8="vppassignments")
								$vb_skipThisItem:=True:C214
								vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"[skip] I haven't been taught to deploy VPP Assignments yet. It's best to let Jamf Pro calculate these."+<>CRLF+<>CRLF
								
							: ([Endpoints:7]API_Endpoint_Name:8="vppinvitations")
								$vb_skipThisItem:=True:C214
								vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"[skip] I haven't been taught to deploy VPP Invitations yet. It's best to let Jamf Pro calculate these."+<>CRLF+<>CRLF
								
							: ([Endpoints:7]API_Endpoint_Name:8="healthcarelistener")
								$vb_skipThisItem:=True:C214
								vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"[skip] I haven't been taught to deploy healthcare listeners yet"+<>CRLF
								
								  // This has no post, just put
								
								  // It also has no get by name, so you can't check for conflicts that way. 
								  // There may be no restriction on name uniqueness anyway. 
								  // We may be able to give it a pass
								
								  // Might be generally more effective to pull the listing XML and then scan the names in there. 
								  // But this would be a bad idea for devices, computers, and users
								
								
								  // ==============================================================================
								  // Some other weird 409 conflict errors to look into...
								
								  //• Sending Mobile device application: Slack
								  //[error] The API returned a "409" error when we tried to add this item.
								  //[info] This usually happens when the XML contains a reference to some other
								  //object (e.g. a site) that doesn't exist on the target Jamf Pro or when
								  //the API is enforcing some other validity check.
								  //[operation] POST to https: //o.jamfcloud.com/JSSResource/mobiledeviceapplications/id/0
								  //[API message] Conflict Error: App is not available for device assignment
								
							: ([Endpoints:7]API_Endpoint_Name:8="healthcarelistenerrule")
								$vb_skipThisItem:=True:C214
								vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"[skip] I haven't been taught to deploy healthcare listener rules yet"+<>CRLF
								
								  // These have post and put
								
								  // But it has no get by name, so you can't check for duplicate name conflicts that way. 
								  // Or maybe there's no restriction on name uniqueness? 
								  // We can skip them for now
								
								
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
									$vb_itemProcessedOK:=False:C215
									$vt_deployed_Note:="HTTP error looking up record number"
								End if 
								
								If ($vb_itemProcessedOK)
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
										$vb_itemProcessedOK:=False:C215
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
				End case 
			End if 
			
			
			If (Not:C34($vb_skipThisItem))
				If ($vb_itemProcessedOK)
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
						$vb_itemProcessedOK:=False:C215
						vt_deployedItemsSummary:=vt_deployedItemsSummary+"[error] Network problem when sending data to the target Jamf Pro Server. ("+String:C10(vl_Error)+")"+<>CRLF
						vt_deployedItemsSummary:=vt_deployedItemsSummary+"[URL] "+$vt_postOrPutRestMethod+" to "+$vt_URL+<>CRLF
						vt_deployedItemsSummary:=vt_deployedItemsSummary+"------------ XML ------------"+<>CRLF
						vt_deployedItemsSummary:=vt_deployedItemsSummary+$vt_xml+<>CRLF
						vt_deployedItemsSummary:=vt_deployedItemsSummary+"---------- END XML ----------"+<>CRLF
						sh_msg_Alert ("There was a network error sending data to Jamf Pro")
						$vt_deployed_Note:="Network error sending record"
					End if 
				End if 
				
				If ($vb_itemProcessedOK)  // If we connected to Jamf Pro OK. 
					$vt_httpErrorExplanation:=""  // If there is a problem we'll populate this and print an explanation
					
					If (($vl_httpStatusCode=201) | ($vl_httpStatusCode=200))
						
						Case of 
							: ($vl_httpStatusCode=201)
								  // Request to create or update object successful
								  //$vt_apiResponse == "<?xml version="1.0" encoding="UTF-8"?><policy><id>5</id></policy>"
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
								vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+"  -> [OK] Item created on target."+$vt_newlyCreatedItemID_msg+<>CRLF
								$vt_deployed_Note:="[OK] Item ID on target : "+$vt_newlyCreatedItemID+" (201)"
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
								If ($vt_apiMessage="@Password is required for authentication.")
									$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"This object type requires a password value and the XML doesn't have one. "+<>CRLF
									$vt_deployed_Note:="XML is missing required password attribute"
								Else 
									$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"This usually happens when the XML contains a reference to some other"+<>CRLF
									$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"object (e.g. a site) that doesn't exist on the target Jamf Pro or when"+<>CRLF
									$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"the API is enforcing some other validity check."+<>CRLF
									$vt_deployed_Note:="Conflicting, invalid, or missing data (409)"
								End if 
								
							: ($vl_httpStatusCode=401)
								$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"This usually means we have a bad username and/or password, or your API"+<>CRLF
								$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"username doesn't have write permission. Make sure you've selected the"+<>CRLF
								$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"intended target Jamf Pro from the dropdown menu."+<>CRLF
								If (Current user:C182="Designer")
									$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"[debug][user] "+sh_str_dq ($vt_API_User_Name)+<>CRLF
									$vt_httpErrorExplanation:=$vt_httpErrorExplanation+"[debug][pass] "+sh_str_dq ($vt_API_Password)+<>CRLF
								End if 
								$vt_deployed_Note:="API auth error sending to target (401)"
								
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
							$vb_itemProcessedOK:=False:C215
							deploy_JamfPro_Push_logSendErr ($vl_httpStatusCode;$vt_httpErrorExplanation;$vt_postOrPutRestMethod;$vt_URL;$vt_apiResponse;$vt_xml)
							  // sh_msg_Alert ("There was a problem writing an item to Jamf Pro. Please see the transcript for more information.")
						End if 
					End if   //If (($vl_httpStatusCode=201)|($vl_httpStatusCode=200))
					
				End if   // If (vl_Error#0)
				
				
				If (Not:C34($vb_itemProcessedOK))
					  // $vl_xmlIterator:=Records in selection([XML])+1  // Pop the loop
					
					  // We can add a confirm to see if they want to continue or stop
					  // on a failure. Or just let it run out and risk that some 
					  // downstream items will fail based on a missing dependency
					
				End if 
				
			End if   // If (Not($vb_skipThisItem))
			
			
			
			
			
			  // Add column 
			  // $vt_postOrPutRestMethod 
			
			  // Write outcome to a status array set we can display when we're done
			$vl_TotalItemCount:=$vl_TotalItemCount+1
			APPEND TO ARRAY:C911(at_deployed_Set;[Sets:1]Name:2)
			APPEND TO ARRAY:C911(at_deployed_ItemType;[Endpoints:7]Human_Readable_Plural_Name:2)
			APPEND TO ARRAY:C911(at_deployed_ItemName;[XML:2]HumanReadableItemName:9)
			Case of 
				: ($vt_postOrPutRestMethod=HTTP POST method:K71:2)
					APPEND TO ARRAY:C911(at_deployed_AddedOrUpdated;"Add New")
				: ($vt_postOrPutRestMethod=HTTP PUT method:K71:6)
					APPEND TO ARRAY:C911(at_deployed_AddedOrUpdated;"Update")
				Else 
					APPEND TO ARRAY:C911(at_deployed_AddedOrUpdated;"Unknown")
			End case 
			Case of 
				: ($vb_itemProcessedOK)
					APPEND TO ARRAY:C911(at_deployed_Outcome;"OK")
					APPEND TO ARRAY:C911(al_deploy_rowColors;White:K11:1)
					$vl_TotalItemCount_ok:=$vl_TotalItemCount_ok+1
				: ($vb_skipThisItem)
					APPEND TO ARRAY:C911(at_deployed_Outcome;"Skipped")
					APPEND TO ARRAY:C911(al_deploy_rowColors;Yellow:K11:2)
					$vt_deployed_Note:="I don't know how to import data for this endpoint."
					$vl_TotalItemCount_skip:=$vl_TotalItemCount_skip+1
				: (Not:C34($vb_itemProcessedOK))
					APPEND TO ARRAY:C911(at_deployed_Outcome;"Failed")
					APPEND TO ARRAY:C911(al_deploy_rowColors;Red:K11:4)
					$vl_TotalItemCount_fail:=$vl_TotalItemCount_fail+1
				Else 
					APPEND TO ARRAY:C911(at_deployed_Outcome;"Unknown")
					APPEND TO ARRAY:C911(al_deploy_rowColors;Yellow:K11:2)
					$vt_deployed_Note:="[issue] Status is unknown"
			End case 
			APPEND TO ARRAY:C911(at_deployed_Note;$vt_deployed_Note)
			
			
			
			If (Progress Stopped ($vl_progressProcessRef))
				sh_msg_Alert ("Stop button clicked. Upload to Jamf Pro stopped.")
				$vb_UserInteruptedProcess:=True:C214
				$vl_xmlIterator:=$vl_NumberOfItemsToSave  // pop xml loop
				$vl_pushListIterator:=Records in selection:C76([Sets:1])  // pop sets loop
			End if 
			
			NEXT RECORD:C51([XML:2])
		End for   // For ($vl_xmlIterator;1;Records in selection([XML]))  // Loop through the xml records for the current set
		
	End if 
	NEXT RECORD:C51([Sets:1])
End for   // For ($vl_pushListIterator;1;Records in selection([Sets]))  // Loop throught the list of sets



  // Close progress window
Case of 
	: ($vl_progressProcessRef=1)
		Progress QUIT ($vl_progressProcessRef)
	: ($vl_progressProcessRef>1)
		ON ERR CALL:C155("sh_err_call")
		For ($i;1;$vl_progressProcessRef)
			Progress QUIT ($i)
		End for 
		ON ERR CALL:C155("")
End case 

vt_deployJamfProSummary:=""
If ($vb_UserInteruptedProcess)
	vt_deployJamfProSummary:=vt_deployJamfProSummary+"Upload cancelled after "
Else 
	vt_deployJamfProSummary:=vt_deployJamfProSummary+"Uploaded a total of "
End if 
vt_deployJamfProSummary:=vt_deployJamfProSummary+String:C10($vl_TotalItemCount)+" "+sh_str_getSingularForm ("items";$vl_TotalItemCount)+" "
vt_deployJamfProSummary:=vt_deployJamfProSummary+"from "+String:C10($vl_TotalSetCount)+" "+sh_str_getSingularForm ("Sets";$vl_TotalSetCount)+". "
vt_deployJamfProSummary:=vt_deployJamfProSummary+"Please see the transcript for additional details."+<>CRLF

vt_deployJamfProSummary:=vt_deployJamfProSummary+"✅ "+String:C10($vl_TotalItemCount_ok)+<>CRLF
vt_deployJamfProSummary:=vt_deployJamfProSummary+"⚠️ "+String:C10($vl_TotalItemCount_skip)+<>CRLF
vt_deployJamfProSummary:=vt_deployJamfProSummary+"🚫 "+String:C10($vl_TotalItemCount_fail)
BEEP:C151

$vl_outcomeFormWindowRef:=Open form window:C675("deploy_outcome")
DIALOG:C40("deploy_outcome")
CLOSE WINDOW:C154($vl_outcomeFormWindowRef)

$0:=$vb_itemProcessedOK
