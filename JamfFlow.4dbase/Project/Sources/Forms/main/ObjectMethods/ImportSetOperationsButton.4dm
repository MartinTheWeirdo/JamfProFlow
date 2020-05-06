Case of 
	: (Form event code:C388=On Load:K2:1)
		vt_NewConfigSetName:=""
		vt_NewConfigSetDescription:=""
		vt_NewConfigSet_ChangeControl:=""
		vt_savedItemsSummary:=""
		at_ImportSetCategory:=0
		
	: (Form event code:C388=On Clicked:K2:4)
		
		
		If (Size of array:C274(at_selectedItemsListBox_names)=0)  //Is anything in the selected items list box? 
			BEEP:C151
			sh_msg_Alert ("Please add some resources to the selected items list.")
		Else 
			
			  //$vt_selectedSourceDataTypeName:=""
			  //$vlItemPos:=Selected list items(vl_selectSourceData)
			  //If ($vlItemPos>0)
			  //GET LIST ITEM(vl_selectSourceData;$vlItemPos;$vlItemRef;$vt_selectedSourceDataTypeName;$hSublist;$vbExpanded)
			  //Else 
			  //BEEP
			  //ABORT
			  //End if 
			
			$vl_setID:=0
			
			  //at_ImportSetOperations
			
			$vt_ImportSetOperation:=sh_arr_getCurrentValue (->at_ImportSetOperations)  // New or update
			If ($vt_ImportSetOperation="Update")
				$vt_UpdateSetName:=sh_arr_getCurrentValue (->at_ImportOps_SetListPopup)  // Name of set to update
			Else 
				$vt_UpdateSetName:=""
			End if 
			$vt_SelectSourceServer:=sh_arr_getCurrentValue (->at_SelectSourceServer)
			
			  // Basic Prechecks
			Case of 
				: (($vt_ImportSetOperation="New") & (vt_NewConfigSetName=""))
					BEEP:C151
					sh_msg_Alert ("Please enter a name for the new set before saving.")
				: (($vt_ImportSetOperation="Update") & ($vt_UpdateSetName=""))
					BEEP:C151
					sh_msg_Alert ("Please select the set you want to update from the popup menu before saving.")
				: ($vt_SelectSourceServer="")
					BEEP:C151
					sh_msg_Alert ("Please select a source server from the popup list before saving.")
				: (Size of array:C274(at_selectedItemsListBox_types)=0)
					BEEP:C151
					sh_msg_Alert ("Please add some items to the selected items list.")
				: (<>vt_currentUser="")
					BEEP:C151
					sh_msg_Alert ("Please login before saving.")
				Else 
					
					  // Cleared pre-checks
					vt_savedItemsSummary:=""
					Case of 
							
						: (at_ImportSetOperations=1)
							  // Save New
							$vl_MatchingSetCount:=0
							SET QUERY DESTINATION:C396(Into variable:K19:4;$vl_MatchingSetCount)
							QUERY:C277([Sets:1];[Sets:1]Name:2=vt_NewConfigSetName)
							SET QUERY DESTINATION:C396(Into current selection:K19:1)
							If ($vl_MatchingSetCount#0)
								sh_msg_Alert ("There's already a saved configuration set named "+sh_str_dq (vt_NewConfigSetName)+". Resolve this by deleting the old version, entering a different name, or switching to the update option.")
								HIGHLIGHT TEXT:C210(vt_NewConfigSetName;1;Length:C16(vt_NewConfigSetName)+1)
							Else 
								  // CREATE NEW SET RECORD
								$vl_setID:=Import_CreateNewSet 
							End if 
							
						: (at_ImportSetOperations=2)
							  // Update Existing
							$vl_sizeOf_at_ImportOps_SetListP:=Size of array:C274(at_ImportOps_SetListPopup)
							If ((at_ImportOps_SetListPopup<1) | (at_ImportOps_SetListPopup>$vl_sizeOf_at_ImportOps_SetListP))
								BEEP:C151
								sh_msg_Alert ("Please select the set you want to update from the popup list before saving.")
								GOTO OBJECT:C206(at_ImportOps_SetListPopup)
							Else 
								  // UPDATE EXISTING SET RECORD
								$vl_setID:=Import_UpdateExistingSet 
							End if 
							
					End case 
					
					If ($vl_setID>0)
						  //
						  // Save the XML items
						  //
						Import_SaveItemList ($vl_setID)
					End if 
					
			End case   //Validations
		End if   // $vb_isSomethingSelected
End case   //Form event
