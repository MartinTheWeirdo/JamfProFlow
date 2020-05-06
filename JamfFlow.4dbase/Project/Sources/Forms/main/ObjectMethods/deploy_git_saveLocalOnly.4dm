If (FORM Event:C1606.code=On Load:K2:1)
	Self:C308->:=1
End if 

If (sh_arr_getCurrentValue (->at_DeployOps_ListTab)="Git")
	If (Self:C308->=1)
		OBJECT SET TITLE:C194(vl_Deploy_go_button;"Save")
	End if 
End if 