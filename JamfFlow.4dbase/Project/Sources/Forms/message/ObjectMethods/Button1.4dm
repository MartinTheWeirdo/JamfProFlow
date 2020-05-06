If (vt_alertDialogButtonText_No="")
	OBJECT SET VISIBLE:C603(vl_customAlertMessageButton_No;False:C215)
Else 
	OBJECT SET TITLE:C194(vl_customAlertMessageButton_No;vt_alertDialogButtonText_No)
End if 