//%attributes = {}
  // api_get_urlToItemByID
  // $vt_itemByIdURL:=api_get_urlToItemByID($vt_itemByIdURL;$vt_itemIdAsString)
  // $vt_URL:=api_get_urlToItemByID($vt_URL+[Endpoints]API_URL_to_lookup_by_id;"0")

  // Singletons look like this... 
  // ../JSSResource/activationcode
  // Multi-records look like this...
  // ../JSSResource/advancedcomputersearches/id/{id}

$vt_itemByIdURL:=$1
If (Count parameters:C259=2)
	$vt_itemIdAsString:=$2
Else 
	$vt_itemIdAsString:="0"
End if 

C_TEXT:C284($vt_itemByIdURL)
C_TEXT:C284($vt_itemUniqueNameValue)
C_LONGINT:C283($vl_position)
C_LONGINT:C283($vl_length)
C_BOOLEAN:C305($vb_valueNeeded)

$vl_position:=0
$vl_length:=0
$vb_valueNeeded:=False:C215
$vb_valueNeeded:=Match regex:C1019("\\{id\\}";$vt_itemByIdURL;1;$vl_position;$vl_length)  // Is there an "{id}" placeholder to replace?

If ($vb_valueNeeded)
	$vt_itemByIdURL:=Delete string:C232($vt_itemByIdURL;$vl_position;$vl_length)+$vt_itemIdAsString  // If so, strip off the placeholder and add the jss record id
End if 

$0:=$vt_itemByIdURL