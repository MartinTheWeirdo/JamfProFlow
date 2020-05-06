//%attributes = {}
  // Import_GetDependencies

  // Clear out previous info from summary text box
vt_selectedItemsSummary:="Including dependencies..."+<>CRLF
$vb_errorDetected:=False:C215

$vl_itemsInList_before:=0
$vl_itemsInList_after:=1
$vl_loopsSoFar:=0
ARRAY TEXT:C222(at_ImportDataTypesChecked;0)  // As we check items we'll add them to this so we don't have to check them more than once

$vb_goodToGo:=False:C215

  // Create some vars we we can group some anomolies we find. We'll write them to the log area when we're done scanning. 
vt_SkippedIcons:=""
vt_SkippedLDAPItems:=""

While ($vl_itemsInList_before#$vl_itemsInList_after)
	  // We are going to add dependencies for the selected items to the list of selected items. 
	  // Some of the added dependencies themselves may have dependencies, so we'll do this repeatedly until no more are found. 
	$vl_itemsInList_before:=Size of array:C274(at_selectedItemsListBox_types)
	
	  //
	  // Get Dependencies for the items in the selected items list box
	  //
	$vb_goodToGo:=Import_GetDependencies_ ($vl_loopsSoFar+1)
	If (Not:C34($vb_goodToGo))
		  // pop the loop
		$vl_itemsInList_before:=$vl_itemsInList_after
	Else 
		$vl_itemsInList_after:=Size of array:C274(at_selectedItemsListBox_types)
		$vl_loopsSoFar:=$vl_loopsSoFar+1
		  //If ($vl_loopsSoFar>2)
		  //  // We'll pop the loop on the third run just incase weird data causes an infinite loop
		  //$vl_itemsInList_before:=$vl_itemsInList_after
		  //End if 
	End if 
End while 

If (vt_SkippedIcons#"")
	vt_selectedItemsSummary:=vt_selectedItemsSummary+"[Note] The following Icons will need to be migrated by hand:"+<>CRLF
	vt_selectedItemsSummary:=vt_selectedItemsSummary+vt_SkippedIcons+<>CRLF
End if 
If (vt_SkippedLDAPItems#"")
	vt_selectedItemsSummary:=vt_selectedItemsSummary+"[note] The following LDAP Groups will need to be migrated by hand:"+<>CRLF
	vt_selectedItemsSummary:=vt_selectedItemsSummary+vt_SkippedLDAPItems+<>CRLF
End if 

If ($vb_goodToGo)
	import_GetItemCounts 
End if 

  //If (Not($vb_errorDetected))
  //End if 