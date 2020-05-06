//%attributes = {}
$wId:=Open form window:C675([UserTable:5];"In")

QUERY:C277([UserTable:5];[UserTable:5]user_name:2=<>vt_currentUser)
If ([UserTable:5]isAdmin:14)
	ALL RECORDS:C47([UserTable:5])
	SET WINDOW TITLE:C213("Modify Users";$wId)
	MODIFY SELECTION:C204([UserTable:5])
Else 
	ALL RECORDS:C47([UserTable:5])
	SET WINDOW TITLE:C213("Display Users";$wId)
	DISPLAY SELECTION:C59([UserTable:5])
End if 

CLOSE WINDOW:C154($wId)
