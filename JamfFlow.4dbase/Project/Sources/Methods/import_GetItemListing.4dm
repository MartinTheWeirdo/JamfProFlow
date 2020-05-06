//%attributes = {}
  // import_GetItemListing
  // Get user selection for server and data type. Send to child function for retrieval from API

$vt_selectedSourceDataTypeName:=$1
$vt_selectedSourceServer:=$2

  // Reset the quick find box
vt_SourceItemSearch:=""
vl_lastMatchedUnselectedRow:=0

  //Reset the listing box
ARRAY BOOLEAN:C223(ab_SourceItems_LB_SelectedRows;0)
ARRAY TEXT:C222(at_sourceItemLB_types;0)
ARRAY LONGINT:C221(al_sourceItemLB_IDs;0)
ARRAY TEXT:C222(at_sourceItemLB_Names;0)

  // Reset the log roll text area
vt_sourceSetSummary:=""

  // Reset the HTTP info box
ARRAY TEXT:C222(at_httpHeader_Keys;0)
ARRAY TEXT:C222(at_httpHeader_Values;0)

  // Use the Jamf Pro API to get selectable data items for this data type

  //
  // SETUPS
  //

If ($vt_selectedSourceServer="")
	BEEP:C151
	sh_msg_Alert ("Please select a source server before selecting a data type.")
Else 
	If ($vt_selectedSourceDataTypeName#"")
		  // Get a list of items for that data type from the source Jamf Pro server
		import_GetItemListing_ ($vt_selectedSourceServer;$vt_selectedSourceDataTypeName)
		BEEP:C151
	End if 
End if   // If ($vt_selectedSourceServer="")


