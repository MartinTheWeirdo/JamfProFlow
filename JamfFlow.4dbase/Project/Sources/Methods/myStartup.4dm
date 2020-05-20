//%attributes = {}
  //myStartup

C_TEXT:C284($1)

Case of 
	: (Count parameters:C259=0)
		
		  // Array of server credentials that we'll build as we need them so we can avoid repetative keychain reads...
		ARRAY TEXT:C222(<>at_credentialCache;0)
		
		  // Will hold preference lookup values cache
		ARRAY TEXT:C222(<>as40_keyValuePairs_Keys;0)
		ARRAY TEXT:C222(<>as40_keyValuePairs_Values;0)
		  // Load keypairs table into an array
		ALL RECORDS:C47([KeyValuePairs:4])
		ORDER BY:C49([KeyValuePairs:4];[KeyValuePairs:4]KeyName:2)
		SELECTION TO ARRAY:C260([KeyValuePairs:4]KeyName:2;<>as40_keyValuePairs_Keys)
		SELECTION TO ARRAY:C260([KeyValuePairs:4]ValueString:3;<>as40_keyValuePairs_Values)
		  // Init prefs table if anything is missing...
		myStartup_prefs 
		
		<>CRLF:=Char:C90(Line feed:K15:40)
		<>DQ:=Char:C90(Double quote:K15:41)
		
		  // Call Login
		SET WINDOW TITLE:C213("Jamf Pro Flow")
		BRING TO FRONT:C326(New process:C317(Current method name:C684;0;"$"+Generate UUID:C1066;"Login"))
		
	Else 
		
		$wId:=Open form window:C675("Login")
		SET WINDOW TITLE:C213("Login";$wId)
		
		Repeat 
			DIALOG:C40("Login")
			If (OK=0)
				$vb_Yes:=sh_msg_Alert ("Would you like to quit the application?";"Quit";"Try again")
				If ($vb_Yes)
					TRACE:C157
					QUIT 4D:C291
				End if 
			End if 
		Until (OK=1)
		
		CLOSE WINDOW:C154($wId)
		$wId:=Open form window:C675("main")
		SET WINDOW TITLE:C213("Jamf Pro Flow";$wId)
		DIALOG:C40("main")
		CLOSE WINDOW:C154($wId)
		
		
End case 

