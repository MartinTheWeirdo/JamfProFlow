  // Button to move source items to selected list
Case of 
	: (Form event code:C388=On Clicked:K2:4)
		  //$vt_CurrentFocusObjectName:=OBJECT Get name(Object with focus)
		  //if ($vt_CurrentFocusObjectName#"ImportOps_NewSet_f1")
		  //end if
		$vb_somethingWasHighlighted:=((Find in array:C230(ab_SourceItems_LB_SelectedRows;True:C214))>0)
		
		For ($i;1;Size of array:C274(ab_SourceItems_LB_SelectedRows))
			If ((ab_SourceItems_LB_SelectedRows{$i}) | (Not:C34($vb_somethingWasHighlighted)))
				  // Either this item is highlighted or nothing is highlighted and we're going to copy all items.
				
				  // Add it to the selected items list
				  // But first make sure the selected item is not already in the selected items list
				$vb_itemIsAlreadySelected:=False:C215
				For ($j;1;Size of array:C274(at_selectedItemsListBox_types))
					If (at_selectedItemsListBox_types{$j}=at_sourceItemLB_types{$i})
						If (String:C10(al_selectedItemsListBox_ids{$j})=String:C10(al_sourceItemLB_IDs{$i}))
							$vb_itemIsAlreadySelected:=True:C214
							$j:=Size of array:C274(at_selectedItemsListBox_types)+1  // Pop the loop
						End if 
					End if 
				End for 
				If (Not:C34($vb_itemIsAlreadySelected))
					APPEND TO ARRAY:C911(at_selectedItemsListBox_types;at_sourceItemLB_types{$i})
					APPEND TO ARRAY:C911(al_selectedItemsListBox_ids;al_sourceItemLB_IDs{$i})
					APPEND TO ARRAY:C911(at_selectedItemsListBox_names;at_sourceItemLB_Names{$i})
				End if 
			End if 
		End for 
		
		MULTI SORT ARRAY:C718(at_selectedItemsListBox_types;>;at_selectedItemsListBox_names;>;al_selectedItemsListBox_ids;>)
		vt_selectedItemsSummary:=""
		import_GetItemCounts 
		
		
End case 
