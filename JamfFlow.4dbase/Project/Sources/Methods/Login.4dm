//%attributes = {}
$vt_username:=$1
$vt_password:=$2

$vb_successfulLogin:=Login_ (vt_username;vt_password)

  // Get a list of existing nicknames so we can check for duplicates if we end up creating a user record
ALL RECORDS:C47([UserTable:5])
SELECTION TO ARRAY:C260([UserTable:5]User_Initials:12;$at_existingNickNames)


If ($vb_successfulLogin)
	QUERY:C277([UserTable:5];[UserTable:5]user_name:2=vt_username)
	
	If (Records in selection:C76([UserTable:5])=0)  // Do we need to create a new record? 
		CREATE RECORD:C68([UserTable:5])
		[UserTable:5]ID:1:=Sequence number:C244([UserTable:5])
		[UserTable:5]user_name:2:=vt_username
		[UserTable:5]first_login_ok_date:9:=Current date:C33
		[UserTable:5]first_login_ok_time:10:=Current time:C178
		$vl_positionOfAtSignInUsername:=Position:C15("@";vt_username)
		If (($vl_positionOfAtSignInUsername>0) & (Length:C16(vt_username)>($vl_positionOfAtSignInUsername+1)))
			[UserTable:5]ad_server_name:4:=Substring:C12(vt_username;$vl_positionOfAtSignInUsername+1)
		End if 
	End if 
	
	[UserTable:5]login_count_ok:5:=[UserTable:5]login_count_ok:5+1
	[UserTable:5]last_login_ok_date:7:=Current date:C33(*)
	[UserTable:5]last_login_ok_time:8:=Current time:C178(*)
	
	  // If the user doesn't have a nickname, get one. 
	  // We'll use it to tag new config sets they create
	If ([UserTable:5]User_Initials:12="")
		  // See if we can calculate one. This works best with first.last@orgname.ext usernames
		$vt_nickname:=vt_username  // Set a default in case we can't come up with something better.
		$vl_positionOfAtSignInUsername:=Position:C15("@";vt_username)  // Ldap user name?
		If ($vl_positionOfAtSignInUsername>1)
			$vt_name:=Substring:C12(vt_username;1;$vl_positionOfAtSignInUsername-1)
			$vl_positionOfPeriodInUsername:=Position:C15(".";$vt_name)
			If (($vl_positionOfPeriodInUsername<2) | ((Length:C16($vt_name))>($vl_positionOfPeriodInUsername+1)))
				$vt_nickname:=$vt_name
			Else 
				$vt_firstName:=Substring:C12($vt_name;1;$vl_positionOfPeriodInUsername-1)
				$vt_firstName:=Uppercase:C13(Substring:C12($vt_firstName;1;1))+Substring:C12($vt_firstName;2;1)
				$vt_lastInitial:=Uppercase:C13(Substring:C12($vt_name;$vl_positionOfPeriodInUsername+1;1))
				$vt_nickname:=$vt_firstName+" "+$vt_lastInitial
			End if 
		End if 
		$vt_nickNameRequestMessage:="Please enter your initials or a nickname..."
		While ([UserTable:5]User_Initials:12="")
			$vt_nickNameEntry:=Request:C163($vt_nickNameRequestMessage;$vt_nickname)
			If ($vt_nickNameEntry#"")
				$vl_nickNameArrayIndex:=Find in array:C230($at_existingNickNames;$vt_nickNameEntry)
				If ($vl_nickNameArrayIndex<1)
					[UserTable:5]User_Initials:12:=$vt_nickNameEntry
				Else 
					$vt_nickNameRequestMessage:="That nickname is already being used by another user. Please try another."
				End if 
			End if 
		End while   //While ([UserTable]User_Initials="")
		[UserTable:5]User_Initials:12:=$vt_nickname
		
	End if   // If ([UserTable]User_Initials="")
	
	  // First time user... show them a warning
	If (Not:C34([UserTable:5]hasSeenWelcomeScrren:15))
		$vl_licenseWinID:=Open form window:C675("License")
		DIALOG:C40("License")
		CLOSE WINDOW:C154($vl_licenseWinID)
		[UserTable:5]hasSeenWelcomeScrren:15:=True:C214
	End if 
	
	<>vt_currentUser:=vt_username
	<>vt_currentUser_Nickname:=[UserTable:5]User_Initials:12
	SAVE RECORD:C53([UserTable:5])
	UNLOAD RECORD:C212([UserTable:5])
End if   // If ($vb_successfulLogin)

$0:=$vb_successfulLogin
