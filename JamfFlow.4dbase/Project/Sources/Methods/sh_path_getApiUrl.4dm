//%attributes = {}
  // sh_path_getApiUrl
  // sh_path_getApiUrl($vt_jssUrl;$vt_itemType {;$vt_FindBy;$vt_FindValue})

$vt_jssUrl:=$1
$vt_itemType:=$2
If (Count parameters:C259=4)
	$vt_FindBy:=$3  // Supply a name or id#
	$vt_FindValue:=$4
Else 
	$vt_FindBy:=$3  // "name" or "id"
	$vt_FindValue:=$4
End if 

$vt_urlEndpointPath:=$vt_itemType
$vt_urlEndpointPath:=Replace string:C233($vt_urlEndpointPath;" ";"")
$vt_urlEndpointPath:=Replace string:C233($vt_urlEndpointPath;"_";"")
$vt_urlEndpointPath:=Lowercase:C14($vt_urlEndpointPath)

$vt_url:=$vt_jssUrl+"/jssresource/"+$vt_urlEndpointPath
If ($vt_FindBy#"")
	$vt_url:=$vt_url+"/"+$vt_FindBy+"/"+$vt_FindValue
End if 

$0:=$vt_url
