//%attributes = {}
  // Login_

$vt_username:=$1
$vt_password:=$2

$vb_successfulLogin:=False:C215
C_TEXT:C284($vt_passwordHash)
C_OBJECT:C1216($o_options)
$o_options:=New object:C1471("algorithm";"bcrypt";"cost";4)
$vt_passwordHash:=Generate password hash:C1533($vt_password;$o_options)

Case of 
	: (($vt_username="Designer") | ($vt_username="Administrator"))
		$vb_successfulLogin:=login_localUser ($vt_username;$vt_password;$vt_passwordHash)
		
	: (Position:C15("@";$vt_username)>0)
		$vb_successfulLogin:=Login_LDAP ($vt_username;$vt_password;$vt_passwordHash)
		
	Else 
		  // I don't know how to process any other username format
		vt_login_error:="Please enter your username in UPN (LDAP) format. E.g. \"firstlast@my.org\""
End case 

$0:=$vb_successfulLogin
