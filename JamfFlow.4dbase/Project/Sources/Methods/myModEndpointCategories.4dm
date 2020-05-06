//%attributes = {"access":"admins","owner":"admins"}
$wId:=Open form window:C675([EndpointCategories:8];"In")

ALL RECORDS:C47([EndpointCategories:8])

QUERY:C277([UserTable:5];[UserTable:5]user_name:2=<>vt_currentUser)
If ([UserTable:5]isAdmin:14)
	SET WINDOW TITLE:C213("Modify Endpoint Categories";$wId)
	MODIFY SELECTION:C204([EndpointCategories:8])
Else 
	SET WINDOW TITLE:C213("Display Endpoint Categories";$wId)
	DISPLAY SELECTION:C59([EndpointCategories:8])
End if 

CLOSE WINDOW:C154($wId)
