//%attributes = {}
  // import_GetItemListing_arrays

$vt_selectedSourceServer:=$1
$vt_SelectedItemType:=$2

C_OBJECT:C1216($vo_API_GetItemXML)
$vo_API_GetItemXML:=API_GetItemXML ($vt_selectedSourceServer;$vt_SelectedItemType)
Case of 
	: (vl_Error=0)
		vt_sourceSetSummary:="[ok] API call to "+$vt_selectedSourceServer+" succeeded."+<>CRLF
	: (vl_Error=30)
		vt_sourceSetSummary:="[error](30) Could not reach the server for "+$vt_selectedSourceServer+". Check network connection and host name."
	Else 
		vt_sourceSetSummary:="[error] API call to "+$vt_selectedSourceServer+" returned error "+String:C10(vl_Error)+"."
End case 

  // API_GetItemXML  will have also populated at_httpHeader_Keys and at_httpHeader_Values arrays for API fetch details at the bottom of the page. 
  // Fetch info from response object...
C_TEXT:C284($vt_xml)
$vt_xml:=$vo_API_GetItemXML.XML
C_LONGINT:C283($vl_httpStatusCode)
$vl_httpStatusCode:=$vo_API_GetItemXML.httpStatusCode
C_TEXT:C284($vt_url)
$vt_url:=$vo_API_GetItemXML.URL

If ($vl_httpStatusCode#200)
	$vt_xml:=sh_html_stripTags ($vt_xml)
	vt_sourceSetSummary:="[error] The API call to "+$vt_url+<>CRLF*2+" returned an error "+String:C10($vl_httpStatusCode)+"."+<>CRLF+$vt_xml
Else 
	If ($vt_xml#"")  // We got xml back from the API call
		C_TEXT:C284($vt_xmlRootElementReference)
		ON ERR CALL:C155("sh_err_call")
		vl_Error:=0
		$vt_xmlRootElementReference:=DOM Parse XML variable:C720($vt_xml)
		ON ERR CALL:C155("")
		If ((OK=0) | (vl_Error#0))
			$vt_xml:=sh_html_stripTags ($vt_xml)
			vt_sourceSetSummary:="[error] I could not parse the XML returned by the API call. "+String:C10($vl_httpStatusCode)+"."+Char:C90(Carriage return:K15:38)+$vt_xml
		Else 
			  // Parse the XML
			import_GetItemListing_arrays_ ($vt_selectedSourceServer;$vt_SelectedItemType;$vt_xmlRootElementReference)
			If ($vt_xmlRootElementReference#"00000000000000000000000000000000")
				DOM CLOSE XML:C722($vt_xmlRootElementReference)
			End if 
		End if 
	End if   // If ($XML#"")  // We got xml back from the API call
End if 

  // Populate the diagnostic info below the item list. 
  // This will only show the info for the last API call we did, but if there's
  //  an error that's what we'll be interested in seeing. 
INSERT IN ARRAY:C227(at_httpHeader_Keys;1;1)
INSERT IN ARRAY:C227(at_httpHeader_Values;1;1)
at_httpHeader_Keys{1}:="HTTP Code"
at_httpHeader_Values{1}:=String:C10($vl_httpStatusCode)
APPEND TO ARRAY:C911(at_httpHeader_Keys;"XML")
APPEND TO ARRAY:C911(at_httpHeader_Values;$vt_xml)
