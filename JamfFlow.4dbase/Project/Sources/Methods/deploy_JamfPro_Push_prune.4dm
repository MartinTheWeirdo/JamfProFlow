//%attributes = {}
$vt_xml:=$1
$vb_AddDateTimeToName:=$2
$vb_ScopeRemovalNeeded:=$3
$vb_DevicePruningNeeded:=$4
$vt_dateTimeStamp:=$5
$vt_Push_MergeOrCreateNew:=$6


C_TEXT:C284($vt_xml;$1;$vt_dateTimeStamp;$5;$vt_Push_MergeOrCreateNew;$6)
C_BOOLEAN:C305($vb_AddDateTimeToName;$2;$vb_ScopeRemovalNeeded;$3;$vb_DevicePruningNeeded;$4)

$vb_goodToGo:=True:C214


  // First, parse it
vl_error:=0
ON ERR CALL:C155("sh_err_call")
$vt_xmlRootElementReference:=DOM Parse XML variable:C720([XML:2]XML:2)
ON ERR CALL:C155("")
If (vl_error#0)
	sh_msg_Alert ("I couldn't parse the xml for "+[XML:2]ItemType:6+"/"+[XML:2]HumanReadableItemName:9+" in the "+[Sets:1]Name:2+" set.")
	$vb_goodToGo:=False:C215
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
	  // Do we need to prune scoping information?
	If ($vb_ScopeRemovalNeeded)
		If ([Endpoints:7]detail_xml_scoping_xpath:7#"")
			$vt_xmlElementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;[Endpoints:7]detail_xml_scoping_xpath:7)
			If (OK#1)
				  // This is fine... the xml may have been saved without scoping information so there's nothing to prune.
				  // myAlert ("Could not find scoping info in config set "+[Sets]Name+" item "+[XML]ItemType+" "+String([XML]set_id))
				  // ABORT
			Else 
				  // Delete the element
				DOM REMOVE XML ELEMENT:C869($vt_xmlElementRef)
				If (OK#1)
					sh_msg_Alert ("I wasn't able to remove the scoping information from in config set "+[Sets:1]Name:2+" item "+[XML:2]HumanReadableItemName:9)
					ABORT:C156
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
		
		  //$vt_xmlElementRef:=DOM Find XML element($vt_xmlRootReference;"/mobile_device_application")
		  //$vt_xmlElementRef:=DOM Get Root XML element ( $vt_xmlRootReference )
		If (OK=1)
			$vt_child:="<vpp><assign_vpp_device_based_licenses>false</assign_vpp_device_based_licenses><vpp_admin_account_id>-1</vpp_admin_account_id></vpp>"
			  // $vt_xmlElementRef:=DOM Append XML child node($vt_xmlElementRef;XML ELEMENT;$vt_child)
			$vt_xmlElementRef:=DOM Append XML child node:C1080($vt_xmlRootElementReference;XML ELEMENT:K45:20;$vt_child)
			
		End if 
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

If ($vt_xmlRootElementReference#"00000000000000000000000000000000")
	DOM CLOSE XML:C722($vt_xmlRootElementReference)
End if 

$0:=$vt_xml