//%attributes = {"access":"admins","owner":"admins"}
$wId:=Open form window:C675([Endpoints:7];"In")

ALL RECORDS:C47([Endpoints:7])

QUERY:C277([UserTable:5];[UserTable:5]user_name:2=<>vt_currentUser)
If ([UserTable:5]isAdmin:14)
	SET WINDOW TITLE:C213("Modify API Endpoint Data";$wId)
	MODIFY SELECTION:C204([Endpoints:7])
Else 
	SET WINDOW TITLE:C213("Display API Endpoint Data";$wId)
	DISPLAY SELECTION:C59([Endpoints:7])
End if 

CLOSE WINDOW:C154($wId)
