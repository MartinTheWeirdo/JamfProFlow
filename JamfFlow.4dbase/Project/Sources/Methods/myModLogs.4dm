//%attributes = {}
$wId:=Open form window:C675([LogItems:6];"In")

ALL RECORDS:C47([LogItems:6])

QUERY:C277([UserTable:5];[UserTable:5]user_name:2=<>vt_currentUser)
If ([UserTable:5]isAdmin:14)
	SET WINDOW TITLE:C213("Modify [LogItems]";$wId)
	MODIFY SELECTION:C204([LogItems:6])
Else 
	SET WINDOW TITLE:C213("Display [LogItems]";$wId)
	DISPLAY SELECTION:C59([LogItems:6])
End if 

CLOSE WINDOW:C154($wId)
