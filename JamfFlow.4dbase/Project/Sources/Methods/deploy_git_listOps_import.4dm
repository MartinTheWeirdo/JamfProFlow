//%attributes = {}
$vb_goodToGo:=True:C214
vt_deployedItemsSummary:=""

  //$vt_selectedSet:=sh_arr_getCurrentValue (->at_deployLocalGitSetNames;ab_DeploySetsListBoxGit)

  //ab_DeploySetsListBoxGit

$vl_selectedRow:=Find in array:C230(ab_DeploySetsListBoxGit;True:C214)
If ($vl_selectedRow>0)
	$vt_selectedSet:=sh_arr_getCurrentValue (->at_deployLocalGitSetNames;$vl_selectedRow)
Else 
	$vt_selectedSet:=""
End if 

If ($vt_selectedSet="")
	  // Nothing highlighted
	sh_msg_Alert ("Please select a git set from the list.")
	vt_deployedItemsSummary:=vt_deployedItemsSummary+"Nothing imported because you did not select an item from the list of local git sets."+<>CRLF
	BEEP:C151
	$vb_goodToGo:=False:C215
Else 
	vt_deployedItemsSummary:=vt_deployedItemsSummary+"Importing set "+sh_str_dq ($vt_selectedSet)+<>CRLF
End if 


If ($vb_goodToGo)
	  // Something is highlighted. 
	  // Get the info on the record from the set info json file in the repo
	$vt_pathToJSON:=git_get ("LocalRepoPathSystem")+$vt_selectedSet+":set_info.json"
	$vb_setHasMetadata:=((Test path name:C476($vt_pathToJSON))=Is a document:K24:1)
	If ($vb_setHasMetadata)
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"[info] Using set metadata file: "+sh_str_dq ($vt_pathToJSON)+". "+<>CRLF
	Else 
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"[info] No set info.json file found in "+sh_str_dq ($vt_pathToJSON)+". Will create shell record."+<>CRLF
	End if 
End if 


If ($vb_goodToGo)
	  // Is there already a copy of this set in the db?
	QUERY:C277([Sets:1];[Sets:1]Name:2=$vt_selectedSet)
	If (Records in selection:C76([Sets:1])=0)
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"[info] No pre-existing match for this set name. Creating a new set. "+<>CRLF
		CREATE RECORD:C68([Sets:1])
		SAVE RECORD:C53([Sets:1])
	Else 
		$vb_goodToGo:=sh_msg_Alert ("Do you want to replace the existing "+sh_str_dq ($vt_selectedSet)+" set with the git version?";"Yes";"No")
		
		If ($vb_goodToGo)
			  // Get rid of existing XML records
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"[step] Clearing previous API XML records for this set."+<>CRLF
			QUERY:C277([XML:2];[XML:2]set_id:4=[Sets:1]ID:1)
			DELETE SELECTION:C66([XML:2])
		Else 
			vt_deployedItemsSummary:=vt_deployedItemsSummary+"[stop] Operation cancelled by user."+<>CRLF
		End if 
	End if   //If (Records in selection([Sets])=0)
End if 


If ($vb_goodToGo)
	$vl_setID:=[Sets:1]ID:1  // Note the set ID ... we'll need to use it 
	$vt_setID:=String:C10([Sets:1]ID:1)
	vt_deployedItemsSummary:=vt_deployedItemsSummary+"[info] Database set ID: "+$vt_setID+<>CRLF
	
	If ($vb_setHasMetadata)
		$vt_jsonString:=Document to text:C1236($vt_pathToJSON;"UTF-8";Document with native format:K24:19)
		
		  // We need to strip the record ID out of the json because the git source record might be different that the ID in this db. 
		  // Assumes id is the first attribute
		  //$vl_firstCommaPosition:=Position(",";$vt_jsonString)
		  //$vt_jsonString:=Delete string($vt_jsonString;3;$vl_firstCommaPosition-2)
		
		  //$vl_idStartPosition:=Position("[{\"ID\":";$vt_jsonString)
		  //$vl_idEndPosition:=Position(",";$vt_jsonString;$vl_idStartPosition)
		  //  // Put the set id into the source json.
		  //$vt_jsonString:=Substring($vt_jsonString;1;$vl_idStartPosition)+$vt_setID+Substring($vt_jsonString;$vl_idEndPosition)
		JSON TO SELECTION:C1235([Sets:1];$vt_jsonString)
		  // After running that, you have to reload the record so it will show up in the sets list. 
		QUERY:C277([Sets:1];[Sets:1]Name:2=$vt_selectedSet)
	Else 
		  // No metadata. Set may be from Migrator.app
		[Sets:1]Approved_YN:16:=False:C215
		[Sets:1]Approved_Date:12:=!00-00-00!
		[Sets:1]Approved_Time:13:=?00:00:00?
		[Sets:1]ApprovedBy_User:11:=""
		[Sets:1]CreatedBy:8:=<>vt_currentUser
		[Sets:1]CreatedDate:7:=Current date:C33
		[Sets:1]CreatedTime:10:=Current time:C178
		[Sets:1]Description:3:="Imported from git"
		[Sets:1]LastModifiedBy:15:=<>vt_currentUser
		[Sets:1]LastModifiedDate:5:=Current date:C33
		[Sets:1]LastModifiedTime:9:=Current time:C178
		[Sets:1]Name:2:=$vt_selectedSet
		[Sets:1]Shared_YN:17:=False:C215
		SAVE RECORD:C53([Sets:1])
	End if 
End if 


If ($vb_goodToGo)
	vt_deployedItemsSummary:=vt_deployedItemsSummary+"[step] Reading API XML files from the set's category folders."+<>CRLF
	$vt_setPath:=git_get ("LocalRepoPathSystem")+$vt_selectedSet
	FOLDER LIST:C473($vt_setPath;$at_categoryFoldersList)
	For ($vl_categoryFolderIterator;1;Size of array:C274($at_categoryFoldersList))
		$vt_categoryFolderName:=$at_categoryFoldersList{$vl_categoryFolderIterator}
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"Scanning folder: "+sh_str_dq ($vt_categoryFolderName)+<>CRLF
		$vt_categoryPath:=$vt_setPath+":"+$vt_categoryFolderName
		DOCUMENT LIST:C474($vt_categoryPath;$at_categoryFilesList)
		For ($vl_categoryFilesIterator;1;Size of array:C274($at_categoryFilesList))
			  //import the xml to a new xml record
			$vt_xmlFileName:=$at_categoryFilesList{$vl_categoryFilesIterator}
			If ($vt_xmlFileName#"@.xml")
				If ($vt_xmlFileName#".DS_Store")  // Don't bother telling them if you skip .DS_Store. Anything else is unexpected so let them know...
					vt_deployedItemsSummary:=vt_deployedItemsSummary+"Skipping non-xml file: "+sh_str_dq ($vt_xmlFileName)+<>CRLF
				End if 
			Else 
				vt_deployedItemsSummary:=vt_deployedItemsSummary+"Importing File: "+sh_str_dq ($vt_xmlFileName)+<>CRLF
				$vt_xmlFilePath:=$vt_categoryPath+":"+$vt_xmlFileName
				$vt_xml:=Document to text:C1236($vt_xmlFilePath;"UTF-8";Document with native format:K24:19)
				
				  // Parse it
				vl_error:=0
				ON ERR CALL:C155("sh_err_call")
				$vt_xmlRootElementReference:=DOM Parse XML variable:C720($vt_xml)
				ON ERR CALL:C155("")
				If (vl_error#0)
					sh_msg_Alert ("I couldn't parse the xml for file "+sh_str_dq ($vt_xmlFileName)+" in the "+sh_str_dq ($vt_categoryFolderName)+" folder. Stopping")
					$vb_goodToGo:=False:C215
				End if 
				
				  // Get root element tag
				If ($vb_goodToGo)
					$vt_rootItemTag:=""
					DOM GET XML ELEMENT NAME:C730($vt_xmlRootElementReference;$vt_rootItemTag)
					If ($vt_rootItemTag="")
						  // This should not happen. If it does, the XML is bad. 
						sh_msg_Alert ("I couldn't extract the item type from the XML file "+sh_str_dq ($vt_xmlFileName)+" in the "+sh_str_dq ($vt_categoryFolderName)+" folder. There is likely a problem with this XML.")
						$vt_rootItemTag:=$vt_categoryFolderName  // Use the category folder name instead
					End if 
				End if 
				
				  // Lookup in endpoints
				If ($vb_goodToGo)
					QUERY:C277([Endpoints:7];[Endpoints:7]Detail_XML_Root_Element_xpath:5="/"+$vt_rootItemTag)
					If (Records in selection:C76([Endpoints:7])#1)
						sh_msg_Alert ("I don't recognize the API endpoint for the XML root ("+$vt_rootItemTag+") in "+sh_str_dq ($vt_xmlFileName)+" in the "+sh_str_dq ($vt_categoryFolderName)+" folder. Stopping")
						$vb_goodToGo:=False:C215
					End if 
				End if 
				
				  // Get item unique name
				If ($vb_goodToGo)
					C_TEXT:C284($vt_itemUniqueName)
					$vt_itemUniqueName:=""
					$vt_xmlElementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;[Endpoints:7]xpath_to_lookup_by_Name:22)
					If (OK=0)
						sh_msg_Alert ("I couldn't find the "+[Endpoints:7]xpath_to_lookup_by_Name:22+" item name in file "+sh_str_dq ($vt_xmlFileName)+" in the "+sh_str_dq ($vt_categoryFolderName)+" folder. I'll use the file name for now, but you should check this record.")
					Else 
						DOM GET XML ELEMENT VALUE:C731($vt_xmlElementRef;$vt_itemUniqueName)
					End if 
					If ($vt_itemUniqueName="")
						sh_msg_Alert ("I couldn't find a value for "+[Endpoints:7]xpath_to_lookup_by_Name:22+" in file "+sh_str_dq ($vt_xmlFileName)+" in the "+sh_str_dq ($vt_categoryFolderName)+" folder. I'll use the file name for now, but you should check this record.")
						$vt_itemUniqueName:=Substring:C12($vt_xmlFileName;1;Length:C16($vt_xmlFileName)-4)  // Strip off the file extension
					End if 
				End if 
				
				  // Get item readable name (if different)
				If ($vb_goodToGo)
					C_TEXT:C284($vt_itemDisplayName)
					$vt_itemDisplayName:=""
					If ([Endpoints:7]xpath_to_lookup_by_Name:22=[Endpoints:7]xpath_to_displayed_Name:19)
						$vt_itemDisplayName:=$vt_itemUniqueName
					Else 
						$vt_xmlElementRef:=DOM Find XML element:C864($vt_xmlRootElementReference;[Endpoints:7]xpath_to_displayed_Name:19)
						If (OK=0)
							$vt_itemDisplayName:=$vt_itemUniqueName
						Else 
							DOM GET XML ELEMENT VALUE:C731($vt_xmlElementRef;$vt_itemDisplayName)
						End if 
						If ($vt_itemDisplayName="")
							sh_msg_Alert ("I couldn't find a value for "+[Endpoints:7]xpath_to_displayed_Name:19+" in file "+sh_str_dq ($vt_xmlFileName)+" in the "+sh_str_dq ($vt_categoryFolderName)+" folder. I'll use the file name for now, but you should check this record.")
							$vt_itemDisplayName:=Substring:C12($vt_xmlFileName;1;Length:C16($vt_xmlFileName)-4)  // Strip off the file extension
						End if 
					End if 
				End if 
				
				If ($vb_goodToGo)
					CREATE RECORD:C68([XML:2])
					[XML:2]API_Unique_Item_Name:3:=$vt_itemUniqueName  // This is something like serial number
					[XML:2]Endpoint_Type_ID:10:=[Endpoints:7]ID:1
					[XML:2]HumanReadableItemName:9:=$vt_itemDisplayName  // This is something like device name
					[XML:2]ID:1:=Sequence number:C244([XML:2])
					[XML:2]ItemType:6:=[Endpoints:7]Human_Readable_Singular_Name:3
					[XML:2]set_id:4:=$vl_setID
					  //[XML]SourceServerItemDetailURL:=""
					  //[XML]SourceServerItemID:=""
					  //[XML]SourceServerURL:=""
					[XML:2]XML:2:=$vt_xml
					SAVE RECORD:C53([XML:2])
				End if 
			End if 
			
			If (Not:C34($vb_goodToGo))
				$vl_categoryFilesIterator:=Size of array:C274($at_categoryFilesList)  // Pop category folder files loop
				$vl_categoryFolderIterator:=Size of array:C274($at_categoryFoldersList)  // Pop category folder loop
			End if 
			
		End for 
	End for 
	
End if   //if($vb_goodToGo)
