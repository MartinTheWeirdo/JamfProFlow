  // We can ofuscate they password a little. 
  // This is not safe but in the abscense of a shared keystore, it's better than plaintext. 
  // You would never store the password for a real server this way.
  // Each use would need to use their own password and store it in their keychain


$vt_plainTextPassword:=Request:C163("Please enter the API user's password.")
If (ok=1)
	VARIABLE TO BLOB:C532($vt_plainTextPassword;$B_Password)
	$vt_folder:=Get 4D folder:C485(Current resources folder:K5:16)
	DOCUMENT TO BLOB:C525($vt_folder+"PrivateKey.txt";$B_PrivateKey)
	ENCRYPT BLOB:C689($B_Password;$B_PrivateKey)
	BLOB TO VARIABLE:C533($B_Password;$vt_EncryptedPassword)
	[JamfProServers:3]API_Password:5:=$vt_EncryptedPassword
End if 

ABORT:C156


  // Do we have the keys? 
$vt_prefvalue_pub:=sh_prefs_getValueForKey ("setting.enc.key.public")
$vt_prefvalue_pri:=sh_prefs_getValueForKey ("setting.enc.key.private")
If (($vt_prefvalue_pub="") | ($vt_prefvalue_pri=""))
	sh_msg_Alert ("I can't encrypt the password. Please check the encryption keys in the preferences table.")
	ABORT:C156
End if 

If ([JamfProServers:3]API_User_Name:4#"")
	$vt_plainTextPassword:=Request:C163("Please enter the password for "+[JamfProServers:3]API_User_Name:4+".")
Else 
	$vt_plainTextPassword:=Request:C163("Please enter the API user's password.")
End if 

If (OK=0)
	ABORT:C156
End if 

  //$vt_prefvalue_pub:=sh_prefs_getValueForKey ("setting.enc.key.public";"";False;"$vt_prefvalue_pub")
TEXT TO BLOB:C554($vt_prefvalue_pri;$B_PrivateKey;UTF8 text with length:K22:16)
TEXT TO BLOB:C554($vt_plainTextPassword;$B_Password;UTF8 text with length:K22:16)

  //airwave-isomer-speedup

  //x:=BLOB to text($B_PrivateKey;UTF8 text without length)
  //y:=BLOB to text($B_Password;UTF8 text without length)

ENCRYPT BLOB:C689($B_Password;$B_PrivateKey)

  //C_BLOB($B_PublicKey;$B_PrivateKey)
  //QUERY([KeyValuePairs];[KeyValuePairs]KeyName="setting.enc.key.public")
  //$B_PublicKey:=[KeyValuePairs]Blob
  //QUERY([KeyValuePairs];[KeyValuePairs]KeyName="setting.enc.key.private")
  //$B_PrivateKey:=[KeyValuePairs]Blob

  //ENCRYPT BLOB($B_Password;$B_PrivateKey)


  // $B_Password is now encrypted.
If (ok=1)
	$vt_encryptedPassword:=BLOB to text:C555($B_Password;UTF8 text without length:K22:17)
	$vt_encryptedPassword:=BLOB to text:C555($B_Password;Mac text without length:K22:10)
	[JamfProServers:3]API_Password:5:=$vt_encryptedPassword
End if 

C_BLOB:C604($B_PublicKey)
TEXT TO BLOB:C554($vt_prefvalue_pub;$B_PublicKey)
$vt_encryptedPassword:=[JamfProServers:3]API_Password:5
TEXT TO BLOB:C554($vt_encryptedPassword;$B_Password;UTF8 text without length:K22:17)
DECRYPT BLOB:C690($B_Password;$B_PublicKey)
$vt_plainTextPassword:=BLOB to text:C555($B_Password;UTF8 text without length:K22:17)

