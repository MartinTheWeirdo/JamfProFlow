If (sh_arr_getCurrentValue (->at_DeployOps_ListTab)="Git")
	If (Self:C308->=1)
		OBJECT SET TITLE:C194(vl_Deploy_go_button;"Push")
	End if 
End if 