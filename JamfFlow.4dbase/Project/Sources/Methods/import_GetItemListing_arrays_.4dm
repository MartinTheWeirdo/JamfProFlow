//%attributes = {}
  // import_GetItemListing_arrays_($vt_selectedSourceServer;$vt_SelectedItemType;$xml_rootRef)

$vt_selectedSourceServer:=$1
$vt_SelectedItemType:=$2
$xml_rootRef:=$3

QUERY:C277([Endpoints:7];[Endpoints:7]Human_Readable_Plural_Name:2=$vt_SelectedItemType)
If ([Endpoints:7]Has_Method_Get:12 & [Endpoints:7]Has_Method_Put:14)  // 
	If ([Endpoints:7]isSingleton:16)
		If ([Endpoints:7]Import_DisplayNameElementName:25#"")
			$vt_xpath_name:=[Endpoints:7]Import_XPathToRootElement:26+"/"+[Endpoints:7]Import_DisplayNameElementName:25
			$vt_Name_elementRef:=DOM Find XML element:C864($xml_rootRef;$vt_xpath_name)
			DOM GET XML ELEMENT VALUE:C731($vt_Name_elementRef;$vt_name)
		Else 
			$vt_name:="Settings"
		End if 
		APPEND TO ARRAY:C911(at_sourceItemLB_types;$vt_SelectedItemType)
		APPEND TO ARRAY:C911(al_sourceItemLB_IDs;0)
		APPEND TO ARRAY:C911(at_sourceItemLB_Names;$vt_Name)
	Else 
		  // This is a multi-instance endpoint
		
		  // How many items are there? 
		ON ERR CALL:C155("sh_err_call")
		$vl_itemCount:=-1
		$vt_XPathToSizeElement:=[Endpoints:7]Import_XPathToRootElement:26+"/size"
		$vt_ItemCountElementRef:=DOM Find XML element:C864($xml_rootRef;$vt_XPathToSizeElement)
		DOM GET XML ELEMENT VALUE:C731($vt_ItemCountElementRef;$vl_itemCount)
		If ($vl_itemCount=-1)
			  // Inconsistency. Accounts has no size element. In this case, we count them for ourself...
			$vt_nameOfCountableElementsTag:=sh_str_getLastWord ([Endpoints:7]Import_XPathToItemElement:6;"/")
			$vt_FirstElementRef:=DOM Find XML element:C864($xml_rootRef;[Endpoints:7]Import_XPathToRootElement:26)  // Find the first element (/computers, /accounts/users) 
			$vl_itemCount:=DOM Count XML elements:C726($vt_FirstElementRef;$vt_nameOfCountableElementsTag)  // How many instances of computer are in computers?
		End if 
		ON ERR CALL:C155("")
		
		If ($vl_itemCount>0)
			For ($vl_itemCountIterator;1;$vl_itemCount)
				$vt_ItemNumberForXpath:="["+String:C10($vl_itemCountIterator)+"]"
				$vt_xpath_id:=[Endpoints:7]Import_XPathToItemElement:6+$vt_ItemNumberForXpath+"/id"  //   /computers/computer[1]/id
				$vt_xpath_name:=[Endpoints:7]Import_XPathToItemElement:6+$vt_ItemNumberForXpath+"/"+[Endpoints:7]Import_DisplayNameElementName:25  //   /computers/computer[1]/name
				$vt_ID_elementRef:=DOM Find XML element:C864($xml_rootRef;$vt_xpath_id)
				$vt_Name_elementRef:=DOM Find XML element:C864($xml_rootRef;$vt_xpath_name)
				C_TEXT:C284($vt_ID;$vt_Name)
				DOM GET XML ELEMENT VALUE:C731($vt_ID_elementRef;$vt_ID)
				DOM GET XML ELEMENT VALUE:C731($vt_Name_elementRef;$vt_Name)
				  //Add a row to the LB Display...
				APPEND TO ARRAY:C911(at_sourceItemLB_types;$vt_SelectedItemType)
				APPEND TO ARRAY:C911(al_sourceItemLB_IDs;Num:C11($vt_ID))
				APPEND TO ARRAY:C911(at_sourceItemLB_Names;$vt_Name)
			End for   // For ($vl_itemCountIterator;1;$vl_itemCount)
		End if   // If ($vt_ItemCount="0")
		
	End if   // If ([Endpoints]isSingleton)
End if   // if ([Endpoints]Has_Method_Get & [Endpoints]Has_Method_Post)

