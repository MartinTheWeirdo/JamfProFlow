  // Button to see if any items have dependecies that haven't been added. 
  // For example, a policy could include packages.

Case of 
	: (Form event code:C388=On Clicked:K2:4)
		If (Size of array:C274(at_selectedItemsListBox_types)=0)
			BEEP:C151
		Else 
			Import_GetDependencies 
		End if 
		
End case 
