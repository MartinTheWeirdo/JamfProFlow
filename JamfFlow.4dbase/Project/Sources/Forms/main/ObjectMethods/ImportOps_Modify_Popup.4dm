Case of 
	: (Form event code:C388=On Data Change:K2:15)
		QUERY:C277([Sets:1];[Sets:1]Name:2=at_ImportOps_SetListPopup{at_ImportOps_SetListPopup})
		vt_NewConfigSetName:=[Sets:1]Name:2
		vt_NewConfigSetDescription:=[Sets:1]Description:3
		vt_NewConfigSet_ChangeControl:=[Sets:1]ChangeControl_Note:6
		$vl_popupIndex:=Find in array:C230(at_ImportSetCategory;[Sets:1]Category:18)
		If ($vl_popupIndex>0)
			at_ImportSetCategory:=$vl_popupIndex
		End if 
End case 