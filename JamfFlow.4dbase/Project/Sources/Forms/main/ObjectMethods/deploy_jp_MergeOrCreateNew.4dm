Case of 
	: ((FORM Event:C1606.code=On Clicked:K2:4) | (FORM Event:C1606.code=On Load:K2:1))
		  // Only allow datetime stamping of item names when we are adding new
		$vt_Push_MergeOrNew_Option:=sh_arr_getCurrentValue (->at_Push_MergeOrNew_Options)
		Case of 
			: ($vt_Push_MergeOrNew_Option="Merge")
				  // We do not allow this option for merge operation
				vl_DeployAddDateCheckbox:=0
				OBJECT SET ENABLED:C1123(vl_DeployAddDateCheckbox;False:C215)
			: ($vt_Push_MergeOrNew_Option="Create New")
				  // We allow this option for create new operation
				OBJECT SET ENABLED:C1123(vl_DeployAddDateCheckbox;True:C214)
		End case 
End case 
