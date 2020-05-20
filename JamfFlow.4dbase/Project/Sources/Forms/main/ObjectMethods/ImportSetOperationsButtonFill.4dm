Case of 
	: (Form event code:C388=On Clicked:K2:4)
		
		If (vt_NewConfigSetName="")
			
			$vt_selectedSourceDataTypeName:=""
			
			  //$vl_ItemPos:=Selected list items(vl_selectSourceData)
			$vl_ItemPos:=Selected list items:C379(*;"SourceDataHierarcicalPopupMenu")
			
			If ($vl_ItemPos>0)
				
				  //GET LIST ITEM(vl_selectSourceData;$vl_ItemPos;$vlItemRef;$vt_selectedSourceDataTypeName;$hSublist;$vbExpanded)
				GET LIST ITEM:C378(*;"SourceDataHierarcicalPopupMenu";$vl_ItemPos;$vlItemRef;$vt_selectedSourceDataTypeName;$hSublist;$vbExpanded)
				
			Else 
				BEEP:C151
				ABORT:C156
			End if 
			
			$vt_SelectSourceServer:=sh_arr_getCurrentValue (->at_SelectSourceServer)
			
			
			$vl_selectedItemsCount:=Size of array:C274(at_selectedItemsListBox_types)
			If ($vl_selectedItemsCount>1)
				$vb_all_same_type:=True:C214
				$vt:=at_selectedItemsListBox_types{1}
				For ($i;2;$vl_selectedItemsCount)
					If (at_selectedItemsListBox_types{$i-1}#at_selectedItemsListBox_types{$i})
						$vb_all_same_type:=False:C215
					End if 
				End for 
			End if 
			
			
			Case of 
				: (Size of array:C274(at_selectedItemsListBox_names)=1)
					vt_NewConfigSetName:=sh_arr_getCurrentValue (->at_selectedItemsListBox_names;1)
				: ($vb_all_same_type)
					  // All the things in selected are of a single type
					vt_NewConfigSetName:=at_selectedItemsListBox_types{1}+" from "+$vt_SelectSourceServer
				: ($vt_selectedSourceDataTypeName="Everything")
					vt_NewConfigSetName:="Everything from "+$vt_SelectSourceServer
				: ($vt_selectedSourceDataTypeName="All Settings")
					vt_NewConfigSetName:="Everything from "+$vt_SelectSourceServer
				Else 
					  // If there's more than one, are they all of one type? 
					$vt:=at_selectedItemsListBox_names{1}
					For ($i;1;Size of array:C274(at_selectedItemsListBox_names))
						If (at_selectedItemsListBox_names{$i}#$vt)
							$vt:=""
							$i:=Size of array:C274(at_selectedItemsListBox_names)
						End if 
					End for 
					If ($vt#"")
						vt_NewConfigSetName:=$vt+" from "+$vt_SelectSourceServer
					Else 
						vt_NewConfigSetName:="Items from "+$vt_SelectSourceServer
					End if 
			End case 
			
			If (vt_NewConfigSetDescription#"")
				  // Appending to an existing description
				  // If the description does not already end in a CR, add one
				$vl_len_NewConfigSetDescription:=Length:C16(vt_NewConfigSetDescription)
				$vl_positionEndCR:=Position:C15(<>CRLF;vt_NewConfigSetDescription;$vl_len_NewConfigSetDescription)
				If ($vl_positionEndCR#$vl_len_NewConfigSetDescription)
					vt_NewConfigSetDescription:=vt_NewConfigSetDescription+<>CRLF
				End if 
				  // Add a devider
				vt_NewConfigSetDescription:=vt_NewConfigSetDescription+"======================="+<>CRLF
			End if 
			
			vt_NewConfigSetDescription:=vt_NewConfigSetDescription+String:C10(Current date:C33)+" "+String:C10(Current time:C178)+" : "+<>vt_currentUser_Nickname+<>CRLF
			$vt_server:=sh_arr_getCurrentValue (->at_SelectSourceServer)
			If ($vt_server#"")
				vt_NewConfigSetDescription:=vt_NewConfigSetDescription+"Server: "+sh_arr_getCurrentValue (->at_SelectSourceServer)+<>CRLF
			End if 
			vt_NewConfigSetDescription:=vt_NewConfigSetDescription+vt_selectedItemsSummary+<>CRLF
			
			  // If there are double CRs at the end, strip one...
			$vl_len_NewConfigSetDescription:=Length:C16(vt_NewConfigSetDescription)
			If ($vl_len_NewConfigSetDescription>1)
				$vl_positionDoubleLineEnd:=Position:C15(<>CRLF*2;vt_NewConfigSetDescription;$vl_len_NewConfigSetDescription-1)
				If ($vl_positionDoubleLineEnd=($vl_len_NewConfigSetDescription-1))
					vt_NewConfigSetDescription:=Substring:C12(vt_NewConfigSetDescription;1;$vl_len_NewConfigSetDescription-1)
				End if 
			End if   // If ($vl_len_NewConfigSetDescription>1)
			
		End if   //If (vt_NewConfigSetName="")
End case   //Form event
