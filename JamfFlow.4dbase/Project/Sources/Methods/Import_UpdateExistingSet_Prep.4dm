//%attributes = {}
  // Import_UpdateExistingSet_Prep

C_TEXT:C284($vt_SetName)
C_LONGINT:C283($vt_SetID)
$vt_SetName:=$1
$vt_SetID:=$2

C_LONGINT:C283($vl_newItemsCount;$vl_updatedItemsCount)
$vl_newItemsCount:=0
$vl_deletedItemsCount:=0

  // For updates, we need to consider what the user is asking us to do. 
$vt_selectedModificationOption:=sh_arr_getCurrentValue (->at_Import_Mod_Options)

$vt_SelectSourceServer:=sh_arr_getCurrentValue (->at_SelectSourceServer)

$vb_GoodToGo:=False:C215
Case of 
	: ($vt_selectedModificationOption="Merge")
		  // If the item is already in the set, it will be updated. New items will be added. 
		  // Loop through selected items. See if each is already in the saved set. If it is, delete it. 
		For ($vl_selectedItemListIterator;1;Size of array:C274(at_selectedItemsListBox_types))
			
			QUERY:C277([Endpoints:7];[Endpoints:7]Human_Readable_Plural_Name:2=at_selectedItemsListBox_types{$vl_selectedItemListIterator})
			
			QUERY:C277([XML:2];[XML:2]set_id:4=$vt_SetID;*)
			QUERY:C277([XML:2]; & ;[XML:2]SourceServerURL:5=$vt_SelectSourceServer;*)
			QUERY:C277([XML:2]; & ;[XML:2]ItemType:6=[Endpoints:7]Human_Readable_Singular_Name:3;*)
			QUERY:C277([XML:2]; & ;[XML:2]SourceServerItemID:7=al_selectedItemsListBox_ids{$vl_selectedItemListIterator})
			If (Records in selection:C76([XML:2])=1)
				DELETE RECORD:C58([XML:2])
				$vl_deletedItemsCount:=$vl_deletedItemsCount+1
			End if 
		End for 
		  // Set transcript message here
		vt_savedItemsSummary:=vt_savedItemsSummary+String:C10($vl_deletedItemsCount)+" items were deleted."+<>CRLF
		$vb_GoodToGo:=True:C214
		
	: ($vt_selectedModificationOption="Reset")
		  // All items in he previously-saved set will be deleted before the new items are added. 
		QUERY:C277([XML:2];[XML:2]set_id:4=$vt_SetID)
		$vl_deletedItemsCount:=Records in selection:C76([XML:2])
		DELETE SELECTION:C66([XML:2])
		$vb_GoodToGo:=True:C214
		  // Set transcript message here
		vt_savedItemsSummary:=vt_savedItemsSummary+String:C10($vl_deletedItemsCount)+" items were deleted."+<>CRLF
		
	Else 
		sh_msg_Alert ("Please re-select an update option.")
End case 

$vb_GoodToGo:=False:C215
