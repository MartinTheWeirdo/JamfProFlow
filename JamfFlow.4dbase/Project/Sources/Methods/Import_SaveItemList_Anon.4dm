//%attributes = {}
  // Import_SaveItemList_Anon
  // $vt_xml:=Import_SaveItemList_Anon($vl_endpointID;$vt_xml)

  // Device name, serial number, UUID, and User and location fields (names, email).
  // No way to know if people are putting LDAP fields with PII into an extension attribute.
  // Names and email in /Users. User and email name in accounts.

  // TO-DO
  // In the parent method, instead of relying on item type in saved records we should pull it from the XML. 
  // $vt_rootElementName:=""
  // DOM GET XML ELEMENT NAME($vt_xmlRootElementReference;$vt_rootElementName)
  // $vb_goodToGo:=($vt_rootElementName#"")
  //QUERY([Endpoints];[Endpoints]Detail_XML_Root_Element_xpath="/"+$vt_rootElementName)
  //$vb_goodToGo:=((Records in selection([Endpoints]))=1)

$vt_xml:=$1

$vb_goodToGo:=True:C214

C_TEXT:C284($vt_xmlRootElementReference)
$vt_xmlRootElementReference:=DOM Parse XML variable:C720($vt_xml)
$vb_goodToGo:=(OK=1)

If (Not:C34($vb_goodToGo))
	vt_savedItemsSummary:=vt_savedItemsSummary+"[error] Anonymize could not find the endpoint record for the "+sh_str_dq ($vt_rootElementName)+" root object."+<>CRLF
Else 
	ARRAY TEXT:C222($at_Detail_XML_PII_XPaths;0)
	ARRAY TEXT:C222($at_Detail_XML_PII_Replacements;0)
	sh_str_splitTextToArray ([Endpoints:7]Detail_XML_PII_XPaths:32;->$at_Detail_XML_PII_XPaths)  // sh_str_splitTextToArray ($vt_ArrayText;$pa_TextArray)
	sh_str_splitTextToArray ([Endpoints:7]Detail_XML_PII_Replacements:33;->$at_Detail_XML_PII_Replacements)  // sh_str_splitTextToArray ($vt_ArrayText;$pa_TextArray)
	$vb_goodToGo:=((Size of array:C274($at_Detail_XML_PII_XPaths))=(Size of array:C274($at_Detail_XML_PII_Replacements)))
End if 

If (Not:C34($vb_goodToGo))
	vt_savedItemsSummary:=vt_savedItemsSummary+"[error] The lists of PII XPaths and Replacements for "+[Endpoints:7]API_Endpoint_Name:8+" are different lengths."+<>CRLF
	sh_msg_Alert ("There was an error when trying to anonymize your data. The PII XPaths and Replacements for "+[Endpoints:7]API_Endpoint_Name:8+" are different lengths.")
	$vb_goodToGo:=False:C215
Else 
	For ($vl_pii_iterator;1;Size of array:C274($at_Detail_XML_PII_XPaths))
		$vt_Detail_XML_PII_XPath:=$at_Detail_XML_PII_XPaths{$vl_pii_iterator}
		$vt_Detail_XML_PII_Replacement:=$at_Detail_XML_PII_Replacements{$vl_pii_iterator}
		$vb_goodToGo:=Import_SaveItemList_Anon_R ($vt_xmlRootElementReference;$vt_Detail_XML_PII_XPath;$vt_Detail_XML_PII_Replacement)
		If (Not:C34($vb_goodToGo))
			$vl_pii_iterator:=Size of array:C274($at_Detail_XML_PII_XPaths)  // Pop the loop
		End if 
	End for   // For ($vl_pii_iterator;1;Size of array($at_Detail_XML_PII_XPaths))
End if 

If ($vb_goodToGo)
	DOM EXPORT TO VAR:C863($vt_xmlRootElementReference;$vt_xml)
	DOM CLOSE XML:C722($vt_xmlRootElementReference)
	$0:=$vt_xml
Else 
	$0:=""
End if 

