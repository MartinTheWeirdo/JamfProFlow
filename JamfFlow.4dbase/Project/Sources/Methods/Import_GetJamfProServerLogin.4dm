//%attributes = {}
  // Import_GetJamfProServerLogin

$vt_ServerURL:=$1

$vt_userPipePass:=""  // What we'll return

  // See if it's in the array of servers we've used previously so we can avoid repetative keychain reads...
$vb_FoundInCache:=False:C215
$vl_credentials_index:=Find in array:C230(<>at_credentialCache;$vt_ServerURL+"|@")  // Initialized in project method myStartup
If ($vl_credentials_index>0)
	  //match found
	$vt_serverPipeUserPipePass:=<>at_credentialCache{$vl_credentials_index}
	$vl_pipePosition:=Position:C15("|";$vt_serverPipeUserPipePass)
	$vt_userPipePass:=Substring:C12($vt_serverPipeUserPipePass;$vl_pipePosition+1)
	If ($vt_userPipePass#"")
		$vb_FoundInCache:=True:C214
	End if 
End if 

If ($vt_userPipePass="")
	  // See if it's in the keychain. 
	$vt_shell_cmd:="security find-generic-password"
	$vt_shell_cmd:=$vt_shell_cmd+" -a "+sh_str_dq ($vt_ServerURL)  // Stick the url in -a
	$vt_shell_cmd:=$vt_shell_cmd+" -s "+sh_str_dq ("JamfUtil_JamfProServer")  // The kind of password in -s
	$vt_shell_cmd:=$vt_shell_cmd+" -w "  // Return the password
	$vt_shell_stdin:=""
	$vt_shell_stdout:=""
	$vt_shell_stderr:=""
	LAUNCH EXTERNAL PROCESS:C811($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
	If ($vt_shell_stderr#"@item could not be found@")
		  // If the item is not found, stdout will be "security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain." errorcode will be "44"
		$vt_userPipePass:=$vt_shell_stdout  // escape double-quotes in passwords? pipes in user?
	End if 
End if 


If ($vt_userPipePass="")  // Not yet found
	  // Check if it's in the db
	QUERY:C277([JamfProServers:3];[JamfProServers:3]URL:2=$vt_ServerURL)
	If (Records in selection:C76([JamfProServers:3])=1)
		If (([JamfProServers:3]isPublic:7=True:C214) & ([JamfProServers:3]API_User_Name:4#"") & ([JamfProServers:3]API_Password:5#""))
			$vt_userPipePass:=[JamfProServers:3]API_User_Name:4+"|"+[JamfProServers:3]API_Password:5
		End if 
	End if 
End if 

$vt_userPipePass:=Replace string:C233($vt_userPipePass;Char:C90(Carriage return:K15:38);"")  // strip off possible trailing return
$vt_userPipePass:=Replace string:C233($vt_userPipePass;Char:C90(Line feed:K15:40);"")  // strip off possible trailing feed

If (($vt_userPipePass#"") & (Not:C34($vb_FoundInCache)))  // If credential found but was not in cache
	$vt_serverPipeUserPipePass:=$vt_ServerURL+"|"+$vt_userPipePass
	APPEND TO ARRAY:C911(<>at_credentialCache;$vt_serverPipeUserPipePass)
End if 

$0:=$vt_userPipePass
