//%attributes = {}
  // Import_SaveItemList_Anon_R_




$vt_xmlRootElementReference:=$1
$vt_Detail_XML_PII_XPath:=$2
$vt_Detail_XML_PII_Replacement:=$3

$vb_goodToGo:=True:C214

ON ERR CALL:C155("sh_err_call")  // Trap errors
$vt_xmlElementReference:=DOM Find XML element:C864($vt_xmlRootElementReference;$vt_Detail_XML_PII_XPath)
ON ERR CALL:C155("")  // Trap errors
If (vl_error#0)
	sh_msg_Alert ("Check the "+sh_str_dq ($vt_Detail_XML_PII_XPath)+" XPath entry in the PII items to be anonymized. It appears to be invalid.")
	$vb_goodToGo:=False:C215
End if 

If (Not:C34(sh_xml_isNullElementRef ($vt_xmlElementReference)))  // Found xpath in XML
	$vt_elementValue:=""
	DOM GET XML ELEMENT VALUE:C731($vt_xmlElementReference;$vt_elementValue)
	If ($vt_elementValue#"")  // Something to replace? 
		Case of 
			: ($vt_Detail_XML_PII_Replacement="-")  // Remove the element
				DOM REMOVE XML ELEMENT:C869($vt_xmlElementReference)
				
			Else 
				$vt_elementValue_anon:=Import_SaveItemList_Anon_R_spec ($vt_elementValue;$vt_Detail_XML_PII_Replacement)
				DOM SET XML ELEMENT VALUE:C868($vt_xmlElementReference;$vt_elementValue_anon)
				
		End case 
	End if   // If ($vt_elementValue#"")  // Something to replace? If not, skip it. 
End if   // If (OK=1)  // Found xpath in XML

$0:=$vb_goodToGo
