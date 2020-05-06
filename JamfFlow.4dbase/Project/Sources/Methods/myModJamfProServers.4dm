//%attributes = {}
$wId:=Open form window:C675([UserTable:5];"In")

ALL RECORDS:C47([JamfProServers:3])

QUERY:C277([UserTable:5];[UserTable:5]user_name:2=<>vt_currentUser)
If ([UserTable:5]isAdmin:14)
	SET WINDOW TITLE:C213("Modify [JamfProServers]";$wId)
	MODIFY SELECTION:C204([JamfProServers:3])
Else 
	SET WINDOW TITLE:C213("Display [JamfProServers]";$wId)
	DISPLAY SELECTION:C59([JamfProServers:3])
End if 

CLOSE WINDOW:C154($wId)
