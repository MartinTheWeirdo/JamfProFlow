  // Save a new jamf pro server

$vb_goodToGo:=False:C215
Case of 
	: (vt_newJamfProServerURL#"https://@")
		vt_newJamfProServerMessage:="Please enter a valid url like \"https://my.jamfcloud.com\" or \"https://my.org.corp:8443\""
		GOTO OBJECT:C206(vt_newJamfProServerURL)
	: (vt_newJamfProServerUsername="")
		vt_newJamfProServerMessage:="Please enter a valid user name."
		GOTO OBJECT:C206(vt_newJamfProServerUsername)
	: (vt_newJamfProServerPassword="")
		vt_newJamfProServerMessage:="Please enter a valid password."
		GOTO OBJECT:C206(vt_newJamfProServerPassword)
	Else 
		$vb_goodToGo:=True:C214
End case 

If ($vb_goodToGo)
	$vl_JamfProServersRecordCount:=0
	SET QUERY DESTINATION:C396(Into variable:K19:4;$vl_JamfProServersRecordCount)
	QUERY:C277([JamfProServers:3];[JamfProServers:3]URL:2=vt_newJamfProServerURL)
	SET QUERY DESTINATION:C396(Into current selection:K19:1)
	If ($vl_JamfProServersRecordCount=0)
		CREATE RECORD:C68([JamfProServers:3])
		[JamfProServers:3]ID:1:=Sequence number:C244([JamfProServers:3])
		[JamfProServers:3]URL:2:=vt_newJamfProServerURL
		[JamfProServers:3]CreatedBy_UserName:3:=<>vt_currentUser
		If (vl_isNewJProServerPublic=1)
			$vt_msg:="Making a server public will share this username and password with other users. Are you sure you want to do that?"
			$vb_Yes:=sh_msg_Alert ($vt_msg;"Yes";"No")
			If ($vb_Yes)
				[JamfProServers:3]isPublic:7:=True:C214
			End if 
		End if 
		SAVE RECORD:C53([JamfProServers:3])
	Else   // Server record already exists
		If (vl_isNewJProServerPublic=1)  // They asked to make it public. I guess we could alter that, but I'm not going to handle that yet. 
			sh_msg_Alert ("This server already exists so I'm not changing it's public/private state. Admins can edit the servers by hand.")
		End if 
	End if 
	
	  // Set password to keychain
	$vt_userPipePass:=vt_newJamfProServerUsername+"|"+vt_newJamfProServerPassword  // escape double-quotes in passwords? pipes in user?
	$vt_userPipePass:=Replace string:C233($vt_userPipePass;Char:C90(Carriage return:K15:38);"")  // strip off possible trailing return
	$vt_userPipePass:=Replace string:C233($vt_userPipePass;Char:C90(Line feed:K15:40);"")  // strip off possible trailing feed
	
	  // security add-internet-password [-h] [-a account] [-s server] [-w password]
	  // security add-generic-password -U -a <account_name> -s <service_name> -w <password>
	$vt_shell_cmd:="security add-generic-password -U"
	$vt_shell_cmd:=$vt_shell_cmd+" -a "+sh_str_dq (vt_newJamfProServerURL)
	$vt_shell_cmd:=$vt_shell_cmd+" -s "+sh_str_dq ("JamfUtil_JamfProServer")
	$vt_shell_cmd:=$vt_shell_cmd+" -w "+sh_str_dq ($vt_userPipePass)
	C_TEXT:C284($vt_shell_cmd;$vt_shell_stderr;$vt_shell_stdin;$vt_shell_stdout)
	$vt_shell_stdin:=""
	$vt_shell_stdout:=""
	$vt_shell_stderr:=""
	LAUNCH EXTERNAL PROCESS:C811($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
	  // Success : OK=1, nothing in stdout or stderr.
	  // FAIL    : OK=1, stderr="security: SecKeychainItemCreateFromContent (<default>): The specified item already exists in the keychain.\n"
	If (OK=1)
		Case of 
			: ($vt_shell_stderr#"")
				vt_newJamfProServerMessage:="Problem saving to keychain:\n"+$vt_shell_stderr
			Else 
				  // sh_msg_Alert("Login saved to keychain.")
				ACCEPT:C269
		End case 
	Else 
		vt_newJamfProServerMessage:="Unable to save username and password to keychain. Is it locked?"
	End if 
End if 

vt_newJamfProServerMessage:=""
vt_newJamfProServerURL:=""
vt_newJamfProServerUsername:=""
vt_newJamfProServerPassword:=""
vl_isNewJProServerPublic:=0


  //  // Set
  //$vt_userPipePass:=sh_str_dq (vt_username+"|"+vt_password)  // We'd need to escape double-quotes in passwords
  //C_TEXT($vt_shell_cmd;$vt_shell_stderr;$vt_shell_stdin;$vt_shell_stdout)
  //$vt_appName:=sh_str_dq ("JamfProFlow")
  //$vt_shell_cmd:="security add-generic-password -U -a "+$vt_appName+" -s "+$vt_appName+" -w "+$vt_userPipePass
  //  // Success : OK=1, nothing in stdout or stderr.
  //  // FAIL    : OK=1, stderr="security: SecKeychainItemCreateFromContent (<default>): The specified item already exists in the keychain.\n"
  //$vt_shell_stdin:=""
  //$vt_shell_stdout:=""
  //$vt_shell_stderr:=""
  //LAUNCH EXTERNAL PROCESS($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
  //If (OK=1)
  //Case of 
  //: ($vt_shell_stderr#"")
  //sh_msg_Alert ("Problem saving to keychain:\n"+$vt_shell_stderr)
  //Else 
  //sh_msg_Alert ("Login saved to keychain.")
  //End case 
  //End if 




  //  // Get
  //vt_username:=""
  //vt_password:=""
  //C_TEXT($vt_shell_cmd;$vt_shell_stderr;$vt_shell_stdin;$vt_shell_stdout)
  //$vt_username:=sh_str_dq (vt_username)
  //$vt_password:=sh_str_dq (vt_password)
  //$vt_appName:=sh_str_dq ("JamfProFlow")
  //$vt_shell_cmd:="security find-generic-password -a "+$vt_appName+" -s "+$vt_appName+" -w"
  //  // PASSWORD EXISTS:
  //  // stdout="passwordplaintext\n"
  //  // PASSWORD DOES NOT EXIST:
  //  // stderr="security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain.\n"
  //$vt_shell_stdin:=""
  //$vt_shell_stdout:=""
  //$vt_shell_stderr:=""
  //LAUNCH EXTERNAL PROCESS($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
  //If (OK=1)
  //Case of 
  //: ($vt_shell_stderr#"")
  //  // Not found, most likely. Do nothing in this case. 
  //: ($vt_shell_stdout#"")
  //$vt_shell_stdout:=Substring($vt_shell_stdout;1;Length($vt_shell_stdout)-1)  // Strip trailing newline
  //$vl_pipePosition:=Position("|";$vt_shell_stdout)
  //If (($vl_pipePosition>0) & ($vl_pipePosition<=Length($vt_shell_stdout)))
  //vt_username:=Substring($vt_shell_stdout;1;$vl_pipePosition-1)  // Start to pipe
  //vt_password:=Substring($vt_shell_stdout;$vl_pipePosition+1)  // Pipe to end
  //End if 
  //End case 
  //End if 

