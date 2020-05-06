Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		C_TEXT:C284(vt_selectSourceData)
		vt_selectSourceData:=""
		
	: (FORM Event:C1606.code=On Clicked:K2:4)
		
		$vt_selectedSourceDataTypeName:=""
		$vlItemPos:=Selected list items:C379(vl_selectSourceData)
		If ($vlItemPos>0)
			GET LIST ITEM:C378(vl_selectSourceData;$vlItemPos;$vlItemRef;$vt_selectedSourceDataTypeName;$hSublist;$vbExpanded)
		End if 
		
		  // vt_selectSourceData hold the previously selected value. See if they changed the data type...
		If ($vt_selectedSourceDataTypeName#vt_selectSourceData)  //They picked something new
			If ($vt_selectedSourceDataTypeName="")  // They picked the empty item
				  // Clear the listing arrays
				ARRAY TEXT:C222(at_sourceItemLB_types;0)
				ARRAY LONGINT:C221(al_sourceItemLB_IDs;0)
				ARRAY TEXT:C222(at_sourceItemLB_Names;0)
				  // Clear the search box
				vt_SourceItemSearch:=""
				  // Reset the Data Type popup menu
				SELECT LIST ITEMS BY POSITION:C381(vl_selectSourceData;Count list items:C380(vl_selectSourceData))
				vt_selectSourceData:=""
			Else   //They picked something not blank
				vt_selectSourceData:=$vt_selectedSourceDataTypeName  // Keep track of what has been selected. 
				$vt_selectedSourceServer:=sh_arr_getCurrentValue (->at_SelectSourceServer)
				import_GetItemListing ($vt_selectedSourceDataTypeName;$vt_selectedSourceServer)
			End if   // If ($vt_selectedSourceDataTypeName#"")  //They picked something not blank
		End if   // If ($vt_SubItemText#vt_selectSourceData)  //They picked something new
		
End case 
