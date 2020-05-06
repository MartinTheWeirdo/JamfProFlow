  // Open first highlighted item in Safari

$vb_isSomethingHighlighted:=False:C215

$vt_selectedSourceServer:=sh_arr_getCurrentValue (->at_SelectSourceServer)
If ($vt_selectedSourceServer#"")
	For ($vl_ListIterator;1;Size of array:C274(al_sourceItemLB_IDs))
		If (ab_SourceItems_LB_SelectedRows{$vl_ListIterator})
			$vb_isSomethingHighlighted:=True:C214
			$vt_itemType:=at_sourceItemLB_types{$vl_ListIterator}
			$vt_itemJssID:=String:C10(al_sourceItemLB_IDs{$vl_ListIterator})
			QUERY:C277([Endpoints:7];[Endpoints:7]Human_Readable_Plural_Name:2=$vt_itemType)
			$vt_url:=[Endpoints:7]Detail_Web_Page:4
			If ($vt_itemJssID#"0")
				$vt_url:=Replace string:C233($vt_url;"{id}";$vt_itemJssID)
			End if 
			If ($vt_url#"")
				$vt_url:=$vt_selectedSourceServer+$vt_url
				
				
				  // https://trial.jamfcloud.com/advancedComputerSearches.html?id=4&o=r
				
				OPEN URL:C673($vt_url)
			Else 
				  // This item doesn't have a url... not everything in the API does 
				BEEP:C151
			End if 
			$vl_ListIterator:=Size of array:C274(al_sourceItemLB_IDs)  // Pop the loop
		End if 
	End for 
End if 

If (Not:C34($vb_isSomethingHighlighted))
	BEEP:C151
End if 