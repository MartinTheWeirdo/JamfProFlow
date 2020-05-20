//%attributes = {}
  // Import_SaveItemList_Anon_R 
  // $vt_xml:=Import_SaveItemList_Anon_R ($vt_xmlRootElementReference;$vt_Detail_XML_PII_XPath;$vt_Detail_XML_PII_Replacement)

$vt_xmlRootElementReference:=$1
$vt_Detail_XML_PII_XPath:=$2
$vt_Detail_XML_PII_Replacement:=$3

$vb_goodToGo:=True:C214

$vl_posEndOfMultiInstancedPath:=(Position:C15("s/";$vt_Detail_XML_PII_XPath))+1
$vb_multiInstanced:=($vl_posEndOfMultiInstancedPath>1)
If (Not:C34($vb_multiInstanced))
	$vb_goodToGo:=Import_SaveItemList_Anon_R_ ($vt_xmlRootElementReference;$vt_Detail_XML_PII_XPath;$vt_Detail_XML_PII_Replacement)
Else 
	  // Handle multi-instanced items, like the names of certificates installed on a device or the serial numbers of installed hard drives
	  // Get position of / level of multi-instanced object
	
	  // Example PII XPath : /computer/certificates/certificate/common_name
	
	$vt_XpathToItemsParent:=Substring:C12($vt_Detail_XML_PII_XPath;1;$vl_posEndOfMultiInstancedPath)  // /computer/certificates
	$vt_xmlElementReferenceParent:=DOM Find XML element:C864($vt_xmlRootElementReference;$vt_XpathToItemsParent)
	$vl_postionOfSlashAfterMI_item:=Position:C15("/";$vt_Detail_XML_PII_XPath;$vl_posEndOfMultiInstancedPath+2)  // Position of the / after "certificate"
	$vl_lengthOfMultiInstancedItem:=$vl_postionOfSlashAfterMI_item-$vl_posEndOfMultiInstancedPath-1
	$vt_nameOfMultiInstancedItem:=Substring:C12($vt_Detail_XML_PII_XPath;$vl_posEndOfMultiInstancedPath+1;$vl_lengthOfMultiInstancedItem)  // certificate
	$vl_countOfMultiInstancedItem:=DOM Count XML elements:C726($vt_xmlElementReferenceParent;$vt_nameOfMultiInstancedItem)
	$vt_subXPath:=Substring:C12($vt_Detail_XML_PII_XPath;$vl_postionOfSlashAfterMI_item)
	For ($vl_multiInstanceIterator;1;$vl_countOfMultiInstancedItem)
		$vt_XpathToMultiInstancedItem:=$vt_XpathToItemsParent+$vt_nameOfMultiInstancedItem+"["+String:C10($vl_multiInstanceIterator)+"]"+$vt_subXPath  //  /computer/certificates/certificate[1..n]/common_name
		$vb_goodToGo:=Import_SaveItemList_Anon_R_ ($vt_xmlRootElementReference;$vt_XpathToMultiInstancedItem;$vt_Detail_XML_PII_Replacement)
		If (Not:C34($vb_goodToGo))
			$vl_multiInstanceIterator:=$vl_countOfMultiInstancedItem
		End if 
	End for 
	
	  //$vl_posSlashBeforeMultiInstanced:=sh_str_positionOfLast ("/";Substring($vt_Detail_XML_PII_XPath;1;$vl_positionOfMultiInstancedPath))
	  //$vt_XpathOfMultiInstancedItem:=Substring($vt_Detail_XML_PII_XPath;1;$vl_posSlashBeforeMultiInstanced-1)  // /computer
	  //$vt_xmlElementReferenceParent:=DOM Find XML element($vt_xmlRootElementReference;$vt_XpathOfMultiInstancedItem)
	  //$vt_nameOfMultiInstancedItem:=Substring($vt_Detail_XML_PII_XPath;$vl_posSlashBeforeMultiInstanced+1;$vl_positionOfMultiInstancedPath-$vl_posSlashBeforeMultiInstanced)
	  //$vl_countOfMultiInstancedItem:=DOM Count XML elements($vt_xmlElementReferenceParent;$vt_nameOfMultiInstancedItem)
	  //$vt_subXPath:=Substring($vt_Detail_XML_PII_XPath;$vl_positionOfMultiInstancedPath+1)
	  //For ($vl_multiInstanceIterator;1;$vl_countOfMultiInstancedItem)
	  //$vt_XpathToMultiInstancedItem:=$vt_XpathOfMultiInstancedItem+"["+String($vl_multiInstanceIterator)+"]"+$vt_subXPath
	  //Import_SaveItemList_Anon_R_ ($vt_xmlRootElementReference;$vt_XpathToMultiInstancedItem;$vt_Detail_XML_PII_Replacement)
	  //End for 
	
	  //$vt_XpathOfMultiInstancedItem:=Substring($vt_Detail_XML_PII_XPath;1;$vl_positionOfMultiInstancedPath+2)
	  //ARRAY TEXT($at_xmlElementReferences;0)
	  //$vt_xmlElementReference:=DOM Find XML element($vt_xmlRootElementReference;$vt_Detail_XML_PII_XPath;$at_xmlElementReferences)
	  // That won't work, but we can remove the end path, count the parent instances, and loop though them. 
End if   // If (Not($vb_multiInstanced))

$0:=$vb_goodToGo