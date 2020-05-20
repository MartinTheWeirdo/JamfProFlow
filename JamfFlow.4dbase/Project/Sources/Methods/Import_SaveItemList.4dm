//%attributes = {}
  // Import_SaveItemList
  // Called by the save button on the main form/page 1

$vl_SetID:=$1

$vl_itemsSavedCount:=0
$vl_NumberOfItemsToSave:=Size of array:C274(at_selectedItemsListBox_types)

$vl_progressProcessRef:=sh_progress_new ("Saving Configuration Set";900;100)

vt_savedItemsSummary:="Importing configuration items"+<>CRLF

$vb_skipItemsWithIssues:=False:C215

For ($i;1;$vl_NumberOfItemsToSave)
	
	$vl_ID:=Sequence number:C244([XML:2])
	$vt_SourceServerURL:=at_SelectSourceServer{at_SelectSourceServer}
	$vt_ItemType:=at_selectedItemsListBox_types{$i}
	
	QUERY:C277([Endpoints:7];[Endpoints:7]Human_Readable_Plural_Name:2=$vt_ItemType)
	$vl_endpointID:=[Endpoints:7]ID:1
	$vt_endpointType:=[Endpoints:7]Human_Readable_Singular_Name:3
	
	$vl_SourceServerItemID:=al_selectedItemsListBox_ids{$i}
	$vt_SourceServerItemName:=at_selectedItemsListBox_names{$i}
	
	Progress SET PROGRESS ($vl_progressProcessRef;$i/$vl_NumberOfItemsToSave;$vt_ItemType+": "+$vt_SourceServerItemName;False:C215)
	
	vt_savedItemsSummary:=vt_savedItemsSummary+"• "+$vt_endpointType+" "+$vt_SourceServerItemName
	
	$vt_SourceServerItemDetailURL:=get_ItemDetailURL ($vt_SourceServerURL;$vt_ItemType;$vl_SourceServerItemID)
	
	C_TEXT:C284($vt_xml)
	C_TEXT:C284($vt_targetServerItemName)
	C_OBJECT:C1216($o_xmlInfo)
	$o_xmlInfo:=API_GetItemXMLSavable ($vt_SourceServerURL;$vt_ItemType;$vl_SourceServerItemID;$vb_skipItemsWithIssues)
	$vt_xml:=$o_xmlInfo.vt_xml
	$vt_API_Unique_Item_Name:=$o_xmlInfo.vt_API_Unique_Item_Name
	$vb_goodToGo:=$o_xmlInfo.vb_goodToGo
	$vb_skipItemsWithIssues:=$o_xmlInfo.vb_skipItemsWithIssues
	
	If ($vb_goodToGo)
		Case of 
			: ($vl_ID=0)
				  //** ERROR - Missing Required value
				TRACE:C157
			: ($vl_SetID=0)
				  //** ERROR - Missing Required value
				TRACE:C157
			: ($vt_SourceServerURL="")
				  //** ERROR - Missing Required value
				TRACE:C157
			: ($vt_ItemType="")
				  //** ERROR - Missing Required value
				TRACE:C157
			: ($vl_endpointID=0)
				  //** ERROR - Missing Required value
				TRACE:C157
			: (([Endpoints:7]isSingleton:16=False:C215) & ($vl_SourceServerItemID=0))
				  //** ERROR - Any item that's not a singleton should have a JSS ID number
				TRACE:C157
			: ($vt_SourceServerItemName="")
				  //** ERROR - Missing Required value
				TRACE:C157
			: ($vt_SourceServerItemDetailURL="")
				  //** ERROR - Missing Required value
				TRACE:C157
			: ($vt_xml="")
				  //** ERROR - Missing Required value
				TRACE:C157
			Else 
				$vb_goodToGo:=True:C214
		End case 
	End if 
	
	If ($vb_goodToGo)
		If (vl_ImportAnonymize=1)
			If (([Endpoints:7]Detail_XML_PII_XPaths:32+[Endpoints:7]Detail_XML_PII_Replacements:33)="")
				vt_savedItemsSummary:=vt_savedItemsSummary+" [no-anon]"
			Else 
				$vt_xml:=Import_SaveItemList_Anon ($vt_xml)
				
				Case of   // If we are updating a field that acts as a lookup value, we'll need to hash that too... 
						
					: ($vt_endpointType="Computer")
						$vt_API_Unique_Item_Name:=Import_SaveItemList_Anon_R_spec ($vt_API_Unique_Item_Name;"<serial>")
						$vt_SourceServerItemName:=Import_SaveItemList_Anon_R_spec ($vt_SourceServerItemName;"Mac_<digest-8>")
						
					: ($vt_endpointType="Mobile device")
						$vt_API_Unique_Item_Name:=Import_SaveItemList_Anon_R_spec ($vt_API_Unique_Item_Name;"<serial>")
						$vt_SourceServerItemName:=Import_SaveItemList_Anon_R_spec ($vt_SourceServerItemName;"i_<digest-8>")
						
					: ($vt_endpointType="User")
						$vt_API_Unique_Item_Name:=Import_SaveItemList_Anon_R_spec ($vt_API_Unique_Item_Name;"<serial>")
						$vt_SourceServerItemName:=Import_SaveItemList_Anon_R_spec ($vt_SourceServerItemName;"i_<digest-8>")
						
				End case 
				
				
				
				
				If ($vt_xml="")
					$vb_goodToGo:=False:C215
					$vb_skipItemsWithIssues:=False:C215  // Force hard stop
				End if 
			End if 
		End if 
	End if 
	
	If ($vb_goodToGo)
		CREATE RECORD:C68([XML:2])
		[XML:2]ID:1:=$vl_ID
		[XML:2]set_id:4:=$vl_SetID
		[XML:2]SourceServerURL:5:=$vt_SourceServerURL
		[XML:2]ItemType:6:=$vt_endpointType
		[XML:2]Endpoint_Type_ID:10:=$vl_endpointID
		[XML:2]SourceServerItemID:7:=$vl_SourceServerItemID
		[XML:2]HumanReadableItemName:9:=$vt_SourceServerItemName
		[XML:2]SourceServerItemDetailURL:8:=$vt_SourceServerItemDetailURL
		[XML:2]API_Unique_Item_Name:3:=$vt_API_Unique_Item_Name
		[XML:2]XML:2:=$vt_xml
		[XML:2]PushPriority:11:=[Endpoints:7]Push_Priority:20
		SAVE RECORD:C53([XML:2])
		If (OK=1)
			$vl_itemsSavedCount:=$vl_itemsSavedCount+1
			$vb_goodToGo:=True:C214
			vt_savedItemsSummary:=vt_savedItemsSummary+" [saved]"+<>CRLF
		End if 
	End if 
	
	If ((Not:C34($vb_goodToGo)) & (Not:C34($vb_skipItemsWithIssues)))
		$i:=$vl_NumberOfItemsToSave  // Pop the loop
		sh_msg_Alert ("Incomplete import... there was an issue importing an item. Please see the transcript for details.")
	End if 
	
	If (Progress Stopped ($vl_progressProcessRef))
		$i:=$vl_NumberOfItemsToSave  // Pop the loop
		sh_msg_Alert ("Stop button clicked. Import stopped.")
	End if 
	
End for 

sh_prg_close ($vl_progressProcessRef)  // Close progress window


  // Cleanup and messaging
If (($vb_goodToGo) & (Not:C34($vb_skipItemsWithIssues)))  // We ended without any terminating errors and we did not have to skip any bad items? 
	  // Calculate a message to tell them what we just did. 
	$vt_ImportSetOperation:=sh_arr_getCurrentValue (->at_ImportSetOperations)  // New or update
	Case of 
		: ($vt_ImportSetOperation="New")
			$vt_doneMessage:="Saved "+String:C10($vl_itemsSavedCount)+" items as "+sh_str_dq (vt_NewConfigSetName)+"."
		: ($vt_ImportSetOperation="Update")
			$vt_UpdateSetName:=sh_arr_getCurrentValue (->at_ImportOps_SetListPopup)  // New or update
			$vt_doneMessage:="Saved "+String:C10($vl_itemsSavedCount)+" items to "+sh_str_dq ($vt_UpdateSetName)+"."
	End case 
	
	sh_msg_Alert ($vt_doneMessage)
	
	  // Clear values on the save set entry areas
	vt_NewConfigSetName:=""
	vt_NewConfigSetDescription:=""
	vt_NewConfigSet_ChangeControl:=""
	at_ImportSetCategory:=0
	at_ImportOps_SetListPopup:=0
	
End if 
