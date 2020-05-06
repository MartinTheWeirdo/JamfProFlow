Case of 
		
	: (Form event code:C388=On Load:K2:1)
		
		C_TEXT:C284(vt_SourceItemSearch)
		vt_SourceItemSearch:=""
		
		C_TEXT:C284($ObjectName)
		$ObjectName:=OBJECT Get name:C1087(Object current:K67:2)
		SearchPicker SET HELP TEXT ($ObjectName;"Name (\"*\"=wildcard)")
		
		C_LONGINT:C283(vl_lastMatchedUnselectedRow)
		vl_lastMatchedUnselectedRow:=0
		
	: (Form event code:C388=On Losing Focus:K2:8)
		vl_lastMatchedUnselectedRow:=0
		
	: (Form event code:C388=On Data Change:K2:15)
		  // Why does this fire when some other field is changing/on load.etc.?
		
		If (Size of array:C274(ab_SourceItems_LB_SelectedRows)>0)
			If (OBJECT Get name:C1087(Object current:K67:2)="SearchPicker")  // This tool seems to produce a type of 2/text.
				If (Length:C16(Self:C308->)<2)
					  //For ($vl_rowIterator;1;Size of array(ab_SourceItems_LB_SelectedRows))
					  //ab_SourceItems_LB_SelectedRows{$vl_rowIterator}:=False
					  //End for 
				Else 
					C_TEXT:C284($vt_searchString)
					$vt_searchString:=Self:C308->
					$vt_searchString:=Replace string:C233($vt_searchString;"*";"@")
					
					$vl_firstMatchedRow:=0
					
					For ($vl_rowIterator;1;Size of array:C274(ab_SourceItems_LB_SelectedRows))
						If ((at_sourceItemLB_Names{$vl_rowIterator})=($vt_searchString+"@"))
							ab_SourceItems_LB_SelectedRows{$vl_rowIterator}:=True:C214
							If ($vl_firstMatchedRow=0)
								$vl_firstMatchedRow:=$vl_rowIterator  // make a note of the first match we find so we can scroll down to it so the user sees it. 
							End if 
						Else 
							ab_SourceItems_LB_SelectedRows{$vl_rowIterator}:=False:C215
						End if 
					End for 
					
					If ($vl_firstMatchedRow=0)  //no match found
						BEEP:C151
					Else 
						OBJECT SET SCROLL POSITION:C906(ab_SourceItems_LB_SelectedRows;$vl_firstMatchedRow)
					End if   // If ($vl_firstMatchedRow=0)  //no match found
					
				End if 
			End if   // if(type(Focus object->)=Is text)
		End if 
		
		
End case 


  //Case of 

  //: (Form event code=On Load)
  //vt_SourceItemSearch:=""


  //End case 


  //: (Form event code=On Data Change+99999)
  //C_TEXT($vt_searchString)
  //$vt_searchString:=Self->
  //$vt_searchString:=Replace string($vt_searchString;"*";"@")
  //$vl_firstMatchedRow:=Find in array(at_sourceItemLB_Names;$vt_searchString+"@")
  //If ($vl_firstMatchedRow>0)
  //  // If we'd previously matched a row but more entry in find has moved the selection, unselect it if that was it's origional state.
  //If (vl_lastMatchedUnselectedRow>0)
  //If (Size of array(ab_SourceItems_LB_SelectedRows)>=vl_lastMatchedUnselectedRow)
  //ab_SourceItems_LB_SelectedRows{vl_lastMatchedUnselectedRow}:=False
  //End if 
  //End if 

  //If ($vt_searchString#"")
  //  // Make a note of the row we're matching if it's not already selected. 
  //$vb_firstMatchedRow_curntState:=ab_SourceItems_LB_SelectedRows{$vl_firstMatchedRow}
  //If (Not($vb_firstMatchedRow_curntState))
  //vl_lastMatchedUnselectedRow:=$vl_firstMatchedRow
  //End if 
  //ab_SourceItems_LB_SelectedRows{$vl_firstMatchedRow}:=True
  //OBJECT SET SCROLL POSITION(ab_SourceItems_LB_SelectedRows;$vl_firstMatchedRow)
  //End if 
  //Else 
  //If ($vt_searchString#"")
  //BEEP
  //End if 
  //End if 

