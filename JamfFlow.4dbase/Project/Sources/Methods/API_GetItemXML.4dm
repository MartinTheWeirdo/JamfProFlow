//%attributes = {}
  // API_GetItemXML

$vt_selectedSourceServer:=$1
$vt_SelectedItemType:=$2
If (Count parameters:C259=3)
	$vl_selectedItemID:=$3
Else 
	$vl_selectedItemID:=0
End if 

  // Reset http headers display area
ARRAY TEXT:C222(at_httpHeader_Keys;0)
ARRAY TEXT:C222(at_httpHeader_Values;0)

  // Init response vars
$vt_XML:=""
$vl_httpStatusCode:=0


READ ONLY:C145([Endpoints:7])
QUERY:C277([Endpoints:7];[Endpoints:7]Human_Readable_Plural_Name:2=$vt_SelectedItemType)
If (Records in selection:C76([Endpoints:7])#1)
	TRACE:C157
End if 

  // Build the URL
$vt_urlEndpointPath:=[Endpoints:7]API_Endpoint_Name:8
  // There are few oddballs where the api will use different names for things in different places. 
  // Like the path to the item directly is one way, and references to it in other endpoints use different terms
Case of 
	: ($vt_urlEndpointPath="bindings")
		$vt_urlEndpointPath:="directorybindings/id/"+String:C10($vl_selectedItemID)
	: ($vt_urlEndpointPath="accounts")
		  // Accounts is an oddball with two sub-paths...
		  // GET /JSSResource/accounts/groupid/{id}
		  // GET /JSSResource/accounts/userid/5
		  // We will only support accounts for now
		$vt_urlEndpointPath:="accounts/userid/"+String:C10($vl_selectedItemID)
	Else 
		If ($vl_selectedItemID>0)
			$vt_urlEndpointPath:=$vt_urlEndpointPath+"/id/"+String:C10($vl_selectedItemID)
		End if 
End case 

  // Pre-pend the JSSResource bit
$vt_urlEndpointPath:="/JSSResource/"+$vt_urlEndpointPath
$vt_URL:=$vt_selectedSourceServer+$vt_urlEndpointPath

  //Get the data from source Jamf Pro via API...

  // API Username and password?
$vt_userPipePass:=Import_GetJamfProServerLogin ($vt_selectedSourceServer)
If ($vt_userPipePass="")
	sh_msg_Alert ("I couldn't find a username and password for this Jamf Pro. Re-add it using the import server dropdown menu.")
Else 
	$vl_PipePosition:=Position:C15("|";$vt_userPipePass)
	$vt_API_User_Name:=Substring:C12($vt_userPipePass;1;$vl_PipePosition-1)  // escape double-quotes in passwords? pipes in user?
	$vt_API_Password:=Substring:C12($vt_userPipePass;$vl_PipePosition+1)
	  //QUERY([JamfProServers];[JamfProServers]URL=$vt_selectedSourceServer)
	HTTP AUTHENTICATE:C1161($vt_API_User_Name;$vt_API_Password;HTTP basic:K71:8)
	APPEND TO ARRAY:C911(at_httpHeader_Keys;"Accept")
	APPEND TO ARRAY:C911(at_httpHeader_Values;"application/xml")
	$body:=""
	$vl_httpTimeout:=Num:C11(sh_prefs_getValueForKey ("setting.jamf.capi.http.timeout_seconds";"10"))
	HTTP SET OPTION:C1160(HTTP timeout:K71:10;$vl_httpTimeout)
	ON ERR CALL:C155("sh_err_call")
	vl_Error:=0
	$vl_httpStatusCode:=HTTP Request:C1158(HTTP GET method:K71:1;$vt_URL;$body;$vt_XML;at_httpHeader_Keys;at_httpHeader_Values)
	ON ERR CALL:C155("")
End if 

C_OBJECT:C1216($0)
$0:=New object:C1471("XML";$vt_XML;"httpStatusCode";$vl_httpStatusCode;"URL";$vt_URL;"error";vl_Error)
