Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		vt_importablesListBox_State:="Expanded"
		
	: (FORM Event:C1606.code=On Clicked:K2:4)
		Case of 
			: (vt_importablesListBox_State="Expanded")
				LISTBOX COLLAPSE:C1101(ab_SourceItems_LB_SelectedRows)
				vt_importablesListBox_State:="Collapsed"
				
			: (vt_importablesListBox_State="Collapsed")
				LISTBOX EXPAND:C1100(ab_SourceItems_LB_SelectedRows)  // ; recursive
				vt_importablesListBox_State:="Expanded"
			Else 
				  // Should never happen
		End case 
End case 
