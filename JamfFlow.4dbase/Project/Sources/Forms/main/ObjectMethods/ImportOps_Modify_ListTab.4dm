Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		$vt_option:=sh_arr_getCurrentValue (->at_Import_Mod_Options)
		Case of 
			: ($vt_option="Merge")
				OBJECT SET TITLE:C194(*;"ImportSetOperationsButton";"Merge")
			: ($vt_option="Reset")
				OBJECT SET TITLE:C194(*;"ImportSetOperationsButton";"Reset")
				
		End case 
End case 
