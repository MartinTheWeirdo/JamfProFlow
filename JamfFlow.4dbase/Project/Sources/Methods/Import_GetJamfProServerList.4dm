//%attributes = {}
  // Import_GetJamfProServerList

  // Collect a list of jamf pro severs configured for this utility
  // All will be in the table. 
  // Some will have username/password in the keychain. 

$pat_targetArrayPointer:=$1

  // Init array
ARRAY TEXT:C222($pat_targetArrayPointer->;0)

  // See what's public in the db. 
QUERY:C277([JamfProServers:3];[JamfProServers:3]isPublic:7=True:C214)
SELECTION TO ARRAY:C260([JamfProServers:3]URL:2;$pat_targetArrayPointer->)
  //QUERY([JamfProServers];[JamfProServers]Owner_UserName=<>vt_currentUser;*)
  //QUERY([JamfProServers]; | ;[JamfProServers]Owner_UserName="")

  // If the user has a password for any of the non-public jamf pro servers in their keychain, we'll add those as well. 
QUERY:C277([JamfProServers:3];[JamfProServers:3]isPublic:7=False:C215)
For ($vl_serverIterator;1;Records in selection:C76([JamfProServers:3]))
	  // See if it's in the keychain. 
	$vt_shell_cmd:="security find-generic-password"
	$vt_shell_cmd:=$vt_shell_cmd+" -a "+sh_str_dq (vt_newJamfProServerURL)  // Stick the url in -a
	$vt_shell_cmd:=$vt_shell_cmd+" -s "+sh_str_dq ("JamfUtil_JamfProServer")  // The kind of password in -s
	$vt_shell_cmd:=$vt_shell_cmd+" -w "  // Return the password
	$vt_shell_stdin:=""
	$vt_shell_stdout:=""
	$vt_shell_stderr:=""
	LAUNCH EXTERNAL PROCESS:C811($vt_shell_cmd;$vt_shell_stdin;$vt_shell_stdout;$vt_shell_stderr)
	If ($vt_shell_stdout="@item could not be found@")
		  // Not found
		  // If the item is not found, stdout will be "security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain."
		  // errorcode will be "44"
	Else   // Found
		APPEND TO ARRAY:C911($pat_targetArrayPointer->;[JamfProServers:3]URL:2)
		  // $vt_userPipePass:=$vt_username+"|"+$vt_password  // escape double-quotes in passwords? pipes in user?
	End if 
	
End for 

If (Size of array:C274($pat_targetArrayPointer->)=0)
	APPEND TO ARRAY:C911($pat_targetArrayPointer->;"<none>")
End if 

APPEND TO ARRAY:C911($pat_targetArrayPointer->;"Add a new server...")
$pat_targetArrayPointer->:=1  // Select the first server in the list as a default
