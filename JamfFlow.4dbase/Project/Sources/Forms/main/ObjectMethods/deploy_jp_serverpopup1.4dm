  //aSelectSourceServer Drop-down list Object Method
Case of 
	: (Form event code:C388=On Load:K2:1)
		COPY ARRAY:C226(at_SelectSourceServer;Self:C308->)
		
	: (Form event code:C388=On Data Change:K2:15)
		If (sh_arr_getCurrentValue (Self:C308)="Add a new server...")
			$vl_addServerWindowRef:=Open form window:C675("AddJamfProServer";Movable form dialog box:K39:8)
			SET WINDOW TITLE:C213("Add a Jamf Pro Server...";$vl_addServerWindowRef)
			DIALOG:C40("AddJamfProServer")
			CLOSE WINDOW:C154($vl_addServerWindowRef)
			Import_GetJamfProServerList (Self:C308)
		End if 
		
	: (Form event code:C388=On Clicked:K2:4)
		  // this fires even if they don't change the choice. On data change seems better. 
		
End case 
