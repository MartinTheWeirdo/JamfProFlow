//%attributes = {}





ABORT:C156

  // We can ofuscate the password a little. 
  // This is not safe since we have the keys local, but in the abscense of a shared keystore, 
  //  it's better than plaintext. 
  // You would never store the password for a real server this way.
  // Each use would need to use their own password and store it in their keychain

C_TEXT:C284($vt_Password2)

GENERATE ENCRYPTION KEYPAIR:C688($B_PrivateKey;$B_PublicKey)
$vt_folder:=Get 4D folder:C485(Current resources folder:K5:16)
BLOB TO DOCUMENT:C526($vt_folder+"PrivateKey.txt";$B_PrivateKey)
BLOB TO DOCUMENT:C526($vt_folder+"PublicKey.txt";$B_PublicKey)

$vt_plainTextPassword:=""

VARIABLE TO BLOB:C532($vt_plainTextPassword;$B_Password)
DOCUMENT TO BLOB:C525($vt_folder+"PrivateKey.txt";$B_PrivateKey2)
If (OK=1)
	ENCRYPT BLOB:C689($B_Password;$B_PrivateKey2)
End if 

DOCUMENT TO BLOB:C525($vt_folder+"PublicKey.txt";$B_PublicKey2)
If (OK=1)
	DECRYPT BLOB:C690($B_Password;$B_PublicKey2)
End if 

BLOB TO VARIABLE:C533($B_Password;$vt_plainTextPassword2)

ABORT:C156


$vt_folder:=Get 4D folder:C485(Current resources folder:K5:16)
BLOB TO DOCUMENT:C526($vt_folder+"PrivateKey.txt";$B_PrivateKey)
ENCRYPT BLOB:C689($B_Password;$B_PrivateKeys)
BLOB TO VARIABLE:C533($B_Password;$vt_EncryptedPassword)






C_BLOB:C604($B_PublicKey;$B_PrivateKey)
GENERATE ENCRYPTION KEYPAIR:C688($B_PrivateKey;$B_PublicKey)

$vt_PrivateKey:=BLOB to text:C555($B_PrivateKey;UTF8 text with length:K22:16)
$vt_PublicKey:=BLOB to text:C555($B_PublicKey;UTF8 text with length:K22:16)

VARIABLE TO BLOB:C532($vt_PrivateKey;$B_PrivateKey2)
VARIABLE TO BLOB:C532($vt_PublicKey;$B_PublicKey2)

$vt_plainTextPassword:="airwave-isomer-speedup"
VARIABLE TO BLOB:C532($vt_plainTextPassword;$B_Password)
TEXT TO BLOB:C554($vt_plainTextPassword;$B_Password2;UTF8 text with length:K22:16)

ENCRYPT BLOB:C689($B_Password;$B_PrivateKey2)
ENCRYPT BLOB:C689($B_Password;$B_PrivateKey)

DECRYPT BLOB:C690($B_Password2;$B_PublicKey2)
BLOB TO VARIABLE:C533($B_Password2;$vt_plainTextPassword2)
$vt_plainTextPassword2:=BLOB to text:C555($B_Password2;UTF8 text with length:K22:16)



  // ////////////////////////////////////////////////////////////
BLOB TO VARIABLE:C533($B_PrivateKey;$vt_PrivateKey)
BLOB TO VARIABLE:C533($B_PublicKey;$vt_PublicKey)

VARIABLE TO BLOB:C532($vt_PrivateKey;$B_PrivateKey2)
VARIABLE TO BLOB:C532($vt_PublicKey;$B_PublicKey2)

$vt_plainTextPassword:="airwave-isomer-speedup"
VARIABLE TO BLOB:C532($vt_plainTextPassword;$B_Password)


ENCRYPT BLOB:C689($B_Password;$B_PrivateKey2)
ENCRYPT BLOB:C689($B_Password;$B_PrivateKey)

BLOB TO VARIABLE:C533($B_Password;$vt_Password2)
VARIABLE TO BLOB:C532($vt_Password2;$B_Password2)

DECRYPT BLOB:C690($B_Password2;$B_PublicKey2)
BLOB TO VARIABLE:C533($B_Password2;$vt_plainTextPassword2)


ABORT:C156



  // Do we have the keys? 
$vt_prefvalue_pub:=sh_prefs_getValueForKey ("setting.enc.key.public")
$vt_prefvalue_pri:=sh_prefs_getValueForKey ("setting.enc.key.private")
If (($vt_prefvalue_pub="") | ($vt_prefvalue_pri=""))
	sh_msg_Alert ("I can't encrypt the password. Please check the encryption keys in the preferences table.")
	ABORT:C156
End if 

  //If ([JamfProServers]API_User_Name#"")
  //$vt_plainTextPassword:=Request("Please enter the password for "+[JamfProServers]API_User_Name+".")
  //Else 
  //$vt_plainTextPassword:=Request("Please enter the API user's password.")
  //End if 

$vt_plainTextPassword:="airwave-isomer-speedup"

  //If (OK=0)
  //ABORT
  //End if 

  //$vt_prefvalue_pub:=sh_prefs_getValueForKey ("setting.enc.key.public";"";False;"$vt_prefvalue_pub")
TEXT TO BLOB:C554($vt_prefvalue_pri;$B_PrivateKey;UTF8 text with length:K22:16)
TEXT TO BLOB:C554($vt_plainTextPassword;$B_Password;UTF8 text with length:K22:16)

  //airwave-isomer-speedup

  //x:=BLOB to text($B_PrivateKey;UTF8 text without length)
  //y:=BLOB to text($B_Password;UTF8 text without length)

ENCRYPT BLOB:C689($B_Password;$B_PrivateKey)

C_BLOB:C604($B_PublicKey;$B_PrivateKey)
QUERY:C277([KeyValuePairs:4];[KeyValuePairs:4]KeyName:2="setting.enc.key.public")
$B_PublicKey:=[KeyValuePairs:4]Blob:5
QUERY:C277([KeyValuePairs:4];[KeyValuePairs:4]KeyName:2="setting.enc.key.private")
$B_PrivateKey:=[KeyValuePairs:4]Blob:5
ENCRYPT BLOB:C689($B_Password;$B_PrivateKey)


  // $B_Password is now encrypted.
If (ok=1)
	$vt_encryptedPassword:=BLOB to text:C555($B_Password;UTF8 text with length:K22:16)
	$vt_encryptedPassword:=BLOB to text:C555($B_Password;Mac text with length:K22:9)
	
	BLOB TO VARIABLE:C533($B_Password;$vt_encryptedPassword)
	
	[JamfProServers:3]API_Password:5:=$vt_encryptedPassword
End if 

C_BLOB:C604($B_PublicKey)
TEXT TO BLOB:C554($vt_prefvalue_pub;$B_PublicKey)
$vt_encryptedPassword:=[JamfProServers:3]API_Password:5
TEXT TO BLOB:C554($vt_encryptedPassword;$B_Password;UTF8 text without length:K22:17)
DECRYPT BLOB:C690($B_Password;$B_PublicKey)
$vt_plainTextPassword:=BLOB to text:C555($B_Password;UTF8 text without length:K22:17)

