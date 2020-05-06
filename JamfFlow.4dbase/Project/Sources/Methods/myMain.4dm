//%attributes = {}
  // myApiUtils

C_TEXT:C284($1)

Case of 
	: (Count parameters:C259=0)
		Case of 
			: (<>vt_currentUser="")
				sh_msg_Alert ("Please use File>Login to set your username.")
			: (<>vt_currentUser_Nickname="")
				sh_msg_Alert ("Please use File>Login to set your username.")
			Else 
				BRING TO FRONT:C326(New process:C317(Current method name:C684;0;"$"+Generate UUID:C1066;"Main"))
		End case 
	Else 
		$wId:=Open form window:C675("main")
		SET WINDOW TITLE:C213("Jamf Utils";$wId)
		DIALOG:C40("main")
		CLOSE WINDOW:C154($wId)
End case 
