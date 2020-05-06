//%attributes = {}
  // sh_xml_getXpath
  // $vt_xmlElementName:=sh_xml_getXpath($vt_parentElementRef;$vt_xmlElementName)

C_TEXT:C284($vt_xmlElementXpath)
C_TEXT:C284($vt_xmlElementName)
C_TEXT:C284($vt_xmlElementRef)
C_TEXT:C284($vt_parentElementRef)

$vt_xmlElementRef:=$1
$vt_xmlElementXpath:=$2

  // Get the name of this element and pre-pend it to the xpath
DOM GET XML ELEMENT NAME:C730($vt_xmlElementRef;$vt_xmlElementName)
$vt_xmlElementXpath:="/"+$vt_xmlElementName+$vt_xmlElementXpath
  // See if this element has a parent and call this method recursively to add it to the xpath
C_TEXT:C284($vt_xmlElementParentName)
$vt_parentElementRef:=DOM Get parent XML element:C923($vt_xmlElementRef;$vt_xmlElementParentName)

If ($vt_parentElementRef#"00000000000000000000000000000000")
	If ($vt_xmlElementParentName#"#document")
		$vt_xmlElementXpath:=sh_xml_getXpath ($vt_parentElementRef;$vt_xmlElementXpath)
	End if 
End if 

$0:=$vt_xmlElementXpath