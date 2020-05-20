//%attributes = {}
  // deploy_JamfPro_3a_prepXML 

  // Contract: Current record exists in xml and endpoints

$vt_xml:=$1
$vb_AddDateTimeToName:=$2
$vt_dateTimeStamp:=$3
$vt_Push_MergeOrCreateNew:=$4


C_TEXT:C284($vt_xml;$1;$vt_dateTimeStamp;$3;$vt_Push_MergeOrCreateNew;$4)
C_BOOLEAN:C305($vb_AddDateTimeToName;$2)
C_BOOLEAN:C305($vb_ScopeRemovalNeeded;$vb_DevicePruningNeeded)


$vb_goodToGo:=True:C214
$vt_errorMessage:=""


  // Parse the xml...
vl_error:=0
ON ERR CALL:C155("sh_err_call")
$vt_xmlRootElementReference:=DOM Parse XML variable:C720($vt_xml)
ON ERR CALL:C155("")
If (vl_error#0)
	sh_msg_Alert ("I couldn't parse the xml for "+[XML:2]ItemType:6+"/"+[XML:2]HumanReadableItemName:9+" in the "+[Sets:1]Name:2+" set.")
	$vb_goodToGo:=False:C215
End if 




  //If ($vb_goodToGo)
  //$vb_goodToGo:=deploy_JamfPro_Push_prune($vt_xmlRootElementReference;$vb_AddDateTimeToName;$vt_dateTimeStamp;$vt_Push_MergeOrCreateNew)
  //If (Not($vb_goodToGo))
  //$vt_deployed_Note:="Pruning error"
  //End if 
  //End if 


  //  // Check to see if there are any reasons why we might need to manipulate the XML before we send it to the target
  //$vb_ScopeRemovalNeeded:=(([Endpoints]detail_xml_scoping_xpath#"") & $vb_ScopeRemovalRequested)  // Do we need to remove scope? 
  //$vb_DevicePruningNeeded:=(vl_DeployPruneDeviceDetails=1) | (vl_DeployPruneDeviceUser=1)
  //$vb_ExtraPruningNeeded:=([Endpoints]DeployJamfProPruningXpaths#"")
  //$vb_ExtraPruningNeeded:=$vb_ExtraPruningNeeded | ([XML]ItemType="Computer")  // For computers, we need to prune /computer/general/remote_management/management_password_sha256
  //$vb_ExtraPruningNeeded:=$vb_ExtraPruningNeeded | ([XML]ItemType="@ Group")  // For smart computer groups, we need to prune the member info -- the target should calculate that for itself

  //If ($vb_AddDateTimeToName | $vb_ScopeRemovalNeeded | $vb_ExtraPruningNeeded | $vb_DevicePruningNeeded)
  //  // If any of these are true, we'll need to mess with the xml in some way
  //End if   // If ($vb_AddDateTimeToName | $vb_ScopeRemovalNeeded)



  // Prune scoping branch if the "include scoping" check box says the user does not want to include scope. 
If (vl_ImportScopeCheckbox=0)  // Include scoping not selected
	If ([Endpoints:7]detail_xml_scoping_xpath:7#"")
		ON ERR CALL:C155("sh_err_call")
		$vt_elementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;[Endpoints:7]detail_xml_scoping_xpath:7)
		ON ERR CALL:C155("")
		  // If there is no scoping element, no error is thrown, but $vt_elementRef will be "00000000000000000000000000000000"
		If (vl_error#0)
			vt_savedItemsSummary:=vt_savedItemsSummary+"[warn] No scope clause found in the XML."
			LogMessage (Current method name:C684;Current method path:C1201;"XML Parse";"warning";"Error finding scope element")
		Else 
			If (Not:C34(sh_xml_isNullElementRef ($vt_elementRef)))
				ON ERR CALL:C155("sh_err_call")
				DOM REMOVE XML ELEMENT:C869($vt_elementRef)
				ON ERR CALL:C155("")
				If (vl_error#0)
					$vb_goodToGo:=False:C215
					$vt_errorMessage:=$vt_errorMessage+"[warn] Scope removal was requested but I was unable to prune it."+<>CRLF
					$vt_errorMessage:=$vt_errorMessage+"-------------------- XML --------------------"+<>CRLF
					$vt_errorMessage:=$vt_errorMessage+$vt_xml+<>CRLF
				End if 
			End if 
		End if 
	End if 
End if 


If ($vb_goodToGo)
	If ($vb_AddDateTimeToName)  // Do we need to add a datetime to the name?
		If ($vt_Push_MergeOrCreateNew="Create new")  // We will only do this when creating new items
			If ([Endpoints:7]xpath_to_lookup_by_Name:22#"")  // This item has a name element
				$vt_xmlElementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;[Endpoints:7]xpath_to_lookup_by_Name:22)
				If (OK#1)
					sh_msg_Alert ("Could not find name element for config set "+[Sets:1]Name:2+" item "+[XML:2]ItemType:6+" "+String:C10([XML:2]set_id:4))
					$vb_goodToGo:=False:C215
				Else 
					  // Read element value
					C_TEXT:C284($vt_elementValue)
					$vt_elementValue:=""
					DOM GET XML ELEMENT VALUE:C731($vt_xmlElementRef;$vt_elementValue)
					  // add datetime to element value 
					C_TEXT:C284($vt_itemNameWithDateTimeStamp)
					$vt_itemNameWithDateTimeStamp:=$vt_elementValue+$vt_dateTimeStamp
					  // put it back in the xml
					DOM SET XML ELEMENT VALUE:C868($vt_xmlElementRef;$vt_itemNameWithDateTimeStamp)
				End if 
			End if 
		End if 
	End if 
End if 


If ($vb_goodToGo)
	  // There are some object types that require some extra pruning logic. 
	  // Like taking device lists out of smart groups
	If ([XML:2]ItemType:6="@ Group")
		deploy_JamfPro_Push_prune_smart ($vt_xmlRootElementReference)
	End if 
End if   // If ($vb_goodToGo)


  // Is there anything else we need to prune based on directions in the [Endpoints] settings? 
If ($vb_goodToGo)
	If ([Endpoints:7]DeployJamfProPruningXpaths:24#"")
		$vt_pruningPaths:=[Endpoints:7]DeployJamfProPruningXpaths:24
		While ($vt_pruningPaths#"")
			$vl_eolPosition:=Position:C15("\r";$vt_pruningPaths)
			If ($vl_eolPosition>0)
				$vt_pruningPath:=Substring:C12($vt_pruningPaths;1;$vl_eolPosition-1)
				$vt_pruningPaths:=Substring:C12($vt_pruningPaths;$vl_eolPosition+1)
			Else   // No more carriage returns
				$vt_pruningPath:=$vt_pruningPaths
				$vt_pruningPaths:=""
			End if 
			If ($vt_pruningPath#"")
				$vt_xmlElementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;$vt_pruningPath)
				If (OK#1)
					vt_deployedItemsSummary:="[notice] "+sh_str_dq ($vt_pruningPath)+" is in the list of things to snip off before uploading XML to "
					vt_deployedItemsSummary:=vt_deployedItemsSummary+"Jamf Pro, but I didn't find it in the XML block for"
					vt_deployedItemsSummary:=vt_deployedItemsSummary+[Sets:1]Name:2+" item "+[XML:2]ItemType:6+" "+String:C10([XML:2]set_id:4)+<>CRLF
				Else 
					  // Delete the element
					DOM REMOVE XML ELEMENT:C869($vt_xmlElementRef)
					If (OK#1)
						sh_msg_Alert ("[Error] I wasn't able to remove the "+sh_str_dq ($vt_pruningPath)+" info from the XML for "+[Sets:1]Name:2+"/"+[XML:2]HumanReadableItemName:9)
						ABORT:C156
					End if 
				End if 
			End if 
		End while 
	End if 
End if 


If ($vb_goodToGo)
	If ([Endpoints:7]API_Endpoint_Name:8="mobiledeviceapplications")
		  // Some mobile apps are throwing a 409 even after removing the vpp clause. 
		
		  //The API returned a"409"error when we tried to add this item.
		  //[operation]PUT to https:  //o.jamfcloud.com/JSSResource/mobiledeviceapplications/id/8
		  //[API message] Conflict Error: App is not available for device assignment
		  // Leslie suggests adding an explicit directive that there is no VPP assignment.
		$vt_child:="<vpp><assign_vpp_device_based_licenses>false</assign_vpp_device_based_licenses><vpp_admin_account_id>-1</vpp_admin_account_id></vpp>"
		$vt_xmlElementRef:=DOM Append XML child node:C1080($vt_xmlRootElementReference;XML ELEMENT:K45:20;$vt_child)
	End if 
End if 


If ($vb_goodToGo)
	  // Handle computer management password oddball. 
	  // If you try to send a computer with remote managemnt but you don't send the password, 
	  // you get a 409 "Conflict Error: Management password is required"
	  // I guess the best solution is just to send in a dummy password and then 
	  // You can run a change management password policy to repair. 
	  //<computer>
	  // <general>
	  //  <remote_management>
	  //   <managed>True</managed>
	  //   <management_username>jamfManagement</management_username>
	  //   <management_password_sha256 since="9.23">bb57ce50931257204724d59abadef782b5bc56d7ce8f3064c0edb45cc4170455
	If ([Endpoints:7]Human_Readable_Singular_Name:3="Computer")
		  // Prune the sha-256 from the source. 
		$vt_xpath:="/computer/general/remote_management/management_password_sha256"
		$vt_xmlElementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;$vt_xpath)
		
		If (OK=1)  // Found it
			DOM REMOVE XML ELEMENT:C869($vt_xmlElementRef)
			$vt_xpath:="/computer/general/remote_management"
			$vt_xmlElementRef_rm:=DOM Find XML element:C864($vt_xmlRootElementReference;$vt_xpath)
			If (OK=1)  // Found it
				$vt_xmlElementRef_new:=DOM Append XML child node:C1080($vt_xmlElementRef_rm;XML ELEMENT:K45:20;"<management_password>placeholder</management_password>")
				  //DOM EXPORT TO VAR($vt_xmlElementRef_rm;$vt_xml3)
			End if 
		End if 
	End if 
End if 


  // Do we need to prune device details like installed apps, profiles, etc.?
If ($vb_goodToGo)
	$vt_pruningPaths:=""
	If ($vb_DevicePruningNeeded)  // $vb_DevicePruningNeeded:=Bool((vl_DeployPruneDeviceDetails=1)|(vl_DeployPruneDeviceUser=1))
		Case of 
			: ([Endpoints:7]Human_Readable_Singular_Name:3="Computer")
				If (vl_DeployPruneDeviceDetails=1)
					$vt_pruningPaths:=$vt_pruningPaths+"/computer/certificates"+<>CRLF
					$vt_pruningPaths:=$vt_pruningPaths+"/computer/software"+<>CRLF
					$vt_pruningPaths:=$vt_pruningPaths+"/computer/extension_attributes"+<>CRLF
					$vt_pruningPaths:=$vt_pruningPaths+"/computer/groups_accounts/computer_group_memberships"+<>CRLF
					$vt_pruningPaths:=$vt_pruningPaths+"/computer/iphones"+<>CRLF
					$vt_pruningPaths:=$vt_pruningPaths+"/computer/configuration_profiles"+<>CRLF
				End if 
				If (vl_DeployPruneDeviceUser=1)
					$vt_pruningPaths:=$vt_pruningPaths+"/computer/location"
				End if 
				
			: ([Endpoints:7]Human_Readable_Singular_Name:3="Mobile Device")
				  // TODO
		End case 
	End if 
End if 


If ($vb_goodToGo)
	While ($vt_pruningPaths#"")
		If ($vt_pruningPaths[[Length:C16($vt_pruningPaths)]]=<>CRLF)
			$vt_pruningPaths:=Substring:C12($vt_pruningPaths;1;(Length:C16($vt_pruningPaths)-1))
		End if 
		$vl_eolPosition:=Position:C15("\r";$vt_pruningPaths)
		If ($vl_eolPosition>0)
			$vt_pruningPath:=Substring:C12($vt_pruningPaths;1;$vl_eolPosition-1)
			$vt_pruningPaths:=Substring:C12($vt_pruningPaths;$vl_eolPosition+1)
		Else   // No more carriage returns
			$vt_pruningPath:=$vt_pruningPaths
			$vt_pruningPaths:=""
		End if 
		If ($vt_pruningPath#"")
			$vt_xmlElementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;$vt_pruningPath)
			If (OK#1)
				vt_deployedItemsSummary:="[notice] "+sh_str_dq ($vt_pruningPath)+" is in the list of things to snip off before uploading XML to "
				vt_deployedItemsSummary:=vt_deployedItemsSummary+"Jamf Pro, but I didn't find it in the XML block for"
				vt_deployedItemsSummary:=vt_deployedItemsSummary+[Sets:1]Name:2+" item "+[XML:2]ItemType:6+" "+String:C10([XML:2]set_id:4)+<>CRLF
			Else 
				  // Delete the element
				DOM REMOVE XML ELEMENT:C869($vt_xmlElementRef)
				If (OK#1)
					sh_msg_Alert ("[Error] I wasn't able to remove the "+sh_str_dq ($vt_pruningPath)+" info from the XML for "+[Sets:1]Name:2+"/"+[XML:2]HumanReadableItemName:9)
					ABORT:C156
				End if 
			End if 
		End if 
	End while 
End if 


If ($vb_goodToGo)
	  // Done with changes. Put the results back into the xml var
	DOM EXPORT TO VAR:C863($vt_xmlRootElementReference;$vt_xml)
Else 
	$vt_xml:=""  // Clear the xml to indicate fail
End if 


If (Not:C34(sh_xml_isNullElementRef ($vt_xmlRootElementReference)))
	DOM CLOSE XML:C722($vt_xmlRootElementReference)
End if 


If ($vb_goodToGo)
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


If ($vb_goodToGo)
	  // We have removed references to related id's so things match up by name. 
	  // This is needed because the ID numbers in source and target may be different. 
	  // In the case of an item's category, however, we sometime see a "none assigned" name. 
	  // That will cause an error on post/put so we need to remove it. 
	  // This was noted to occur in the packages payload, but there's no reason 
	  // to include it so we'll strip it out from any place we see it. 
	$vt_xml:=Replace string:C233($vt_xml;"<category>No category assigned</category>";"")
End if 


If ($vb_goodToGo)
	  // Remove any empty tags... 
	  // These shouldn't matter, but there are cases where they seem to. 
	  // E.g., if you try to post an ebook with an empty url it will 500 (unknown error) back at you. 
	  // <ebook>
	  //   <general>
	  //     <url/>
	  // But if you just take out the whole tag, it works.
	$vl_pos_found:=0
	$vl_length_found:=0
	$vt_pattern:="<[^<]+\\/>"
	$vl_startSearchingAtPostion:=1
	While (Match regex:C1019($vt_pattern;$vt_xml;$vl_startSearchingAtPostion;$vl_pos_found;$vl_length_found))
		$vt_xml:=Delete string:C232($vt_xml;$vl_pos_found;$vl_length_found)
	End while 
End if 


If (Not:C34($vb_goodToGo))
	$vt_deployed_Note:="Pruning Error"
Else 
	$vt_deployed_Note:=""
End if 


C_OBJECT:C1216($o_return)
$o_return:=New object:C1471("$vb_goodToGo";$vb_goodToGo;"$vt_xml";$vt_xml;"$vt_deployed_Note";$vt_deployed_Note;"$vt_errorMessage";$vt_errorMessage)
$0:=$o_return