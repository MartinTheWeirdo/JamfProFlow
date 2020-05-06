//%attributes = {}
  // api_get_urlToUniqueNameItem
  // $vt_uniqueNameEndpointURL:=api_get_urlToUniqueNameItem($vt_uniqueNameEndpointURL;$vt_itemUniqueNameValue)
  // $vt_URL:=api_get_urlToUniqueNameItem($vt_URL+[Endpoints]API_URL_to_lookup_by_Name;[XML]API_Unique_Item_Name)

$vt_uniqueNameEndpointURL:=$1
$vt_itemUniqueNameValue:=$2

C_TEXT:C284($vt_uniqueNameEndpointURL)
C_TEXT:C284($vt_itemUniqueNameValue)
C_LONGINT:C283($vl_position)
C_LONGINT:C283($vl_length)
C_BOOLEAN:C305($vb_valueNeeded)

$vl_position:=0
$vl_length:=0
$vb_valueNeeded:=False:C215
$vb_valueNeeded:=Match regex:C1019("\\{.*\\}";$vt_uniqueNameEndpointURL;1;$vl_position;$vl_length)

If ($vb_valueNeeded)
	$vt_uniqueNameEndpointURL:=Delete string:C232($vt_uniqueNameEndpointURL;$vl_position;$vl_length)+sh_http_urlEncode ($vt_itemUniqueNameValue)
End if 

$0:=$vt_uniqueNameEndpointURL