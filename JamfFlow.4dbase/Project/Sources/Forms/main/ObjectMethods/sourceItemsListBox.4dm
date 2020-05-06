Case of 
		
	: (Form event code:C388=On Load:K2:1)
		ARRAY TEXT:C222(at_sourceItemLB_types;0)
		ARRAY LONGINT:C221(al_sourceItemLB_IDs;0)
		ARRAY TEXT:C222(at_sourceItemLB_Names;0)
		OBJECT SET RGB COLORS:C628(at_sourceItemLB_types;"Black";"LAVENDER")
		
	: (Form event code:C388=On Double Clicked:K2:5)
		
		  //What's our source server? 
		$vt_selectedSourceServer:=at_SelectSourceServer{at_SelectSourceServer}
		
		  // What item was double-clicked?
		C_LONGINT:C283($vl_columnNumber)
		C_LONGINT:C283($vl_RowNumber)
		LISTBOX GET CELL POSITION:C971(*;"sourceItemsListBox";$vl_columnNumber;$vl_RowNumber)
		$vt_SelectedItemType:=at_sourceItemLB_types{$vl_RowNumber}
		$vl_selectedItemID:=al_sourceItemLB_IDs{$vl_RowNumber}
		
		  // Get item XML via API
		C_OBJECT:C1216($vo_API_GetItemXML)
		$vo_API_GetItemXML:=API_GetItemXML ($vt_selectedSourceServer;$vt_SelectedItemType;$vl_selectedItemID)
		Case of 
			: (vl_Error=0)
				vt_sourceSetSummary:="[ok] API call to "+$vt_selectedSourceServer+" succeeded."
			: (vl_Error=30)
				vt_sourceSetSummary:="[error](30) Could not reach the server for "+$vt_selectedSourceServer+". Check network connection and host name."
			Else 
				vt_sourceSetSummary:="[error] API call to "+$vt_selectedSourceServer+" returned error "+String:C10(vl_Error)+"."
		End case 
		
		  // API_GetItemXML  will have also populated at_httpHeader_Keys and at_httpHeader_Values arrays for API fetch details at the bottom of the page. 
		  // Fetch info from response object...
		C_TEXT:C284($vt_xml)
		$vt_xml:=$vo_API_GetItemXML.XML
		  //$httpStatusCode:=$vo_API_GetItemXML.httpStatusCode
		
		  //What fields would we like to use when summarizing the XML?
		ARRAY TEXT:C222($at_xpaths;0)
		Case of 
			: ($vt_SelectedItemType="Computers")
				APPEND TO ARRAY:C911($at_xpaths;"/computer/general/name")
				APPEND TO ARRAY:C911($at_xpaths;"/computer/general/serial_number")
				APPEND TO ARRAY:C911($at_xpaths;"/computer/location/username")
				APPEND TO ARRAY:C911($at_xpaths;"/computer/location/realname")
				APPEND TO ARRAY:C911($at_xpaths;"/computer/location/email_address")
				APPEND TO ARRAY:C911($at_xpaths;"/computer/hardware/model")
			: ($vt_SelectedItemType="Mobile Devices")
				APPEND TO ARRAY:C911($at_xpaths;"/mobile_device/general/name")
				APPEND TO ARRAY:C911($at_xpaths;"/mobile_device/general/serial_number")
				APPEND TO ARRAY:C911($at_xpaths;"/mobile_device/general/model")
				APPEND TO ARRAY:C911($at_xpaths;"/mobile_device/location/username")
				APPEND TO ARRAY:C911($at_xpaths;"/mobile_device/location/realname")
				APPEND TO ARRAY:C911($at_xpaths;"/mobile_device/location/email_address")
		End case 
		
		  // Parse the XML
		C_TEXT:C284($vt_xmlRootElementReference)
		$vt_xmlRootElementReference:=DOM Parse XML variable:C720($vt_xml)
		  // Extract info from XML
		If (Size of array:C274($at_xpaths)=0)
			DOM EXPORT TO VAR:C863($vt_xmlRootElementReference;vt_sourceSetSummary)
		Else 
			vt_sourceSetSummary:=""
			For ($i;1;Size of array:C274($at_xpaths))
				$vt_xpath:=$at_xpaths{$i}
				$vt_xmlElementID:=DOM Find XML element:C864($vt_xmlRootElementReference;$vt_xpath)
				DOM GET XML ELEMENT VALUE:C731($vt_xmlElementID;$vt_xmlElementValue)
				  // The value label will be everything after the last "/" in the xpath. E.g. "/mobile_device/location/email_address" => "email_address"
				$vl_pos_found:=0
				$vl_length_found:=0
				$vb_found:=Match regex:C1019("[a-zA-Z]+$";$vt_xpath;1;$vl_pos_found;$vl_length_found)
				If ($vb_found)
					$vt_label:=Substring:C12($vt_xpath;$vl_pos_found;$vl_length_found)
					$vt_label:=Replace string:C233($vt_xpath;"_";" ")
					$vt_label:=Uppercase:C13($vt_label[[1]])+Substring:C12($vt_label;2)
					vt_sourceSetSummary:=vt_sourceSetSummary+$vt_label+" : "+$vt_xmlElementValue+<>CRLF
				End if 
			End for 
			If ($vt_xmlRootElementReference#"00000000000000000000000000000000")
				DOM CLOSE XML:C722($vt_xmlRootElementReference)
			End if 
			vt_sourceSetSummary:=Substring:C12(vt_sourceSetSummary;1;Length:C16(vt_sourceSetSummary)-1)  // Strip the trailing carriage return
		End if 
		
		
		
		
		
	: (Form event code:C388=On Begin Drag Over:K2:44)
		  //C_LONGINT($vl_columnNumber)
		  //C_LONGINT($vl_RowNumber)
		  //LISTBOX GET CELL POSITION(*;"sourceItemsListBox";$vl_columnNumber;$vl_RowNumber)
		  //$vt_SelectedItemType:=at_sourceItemLB_types{$vl_RowNumber}
		  //$vl_selectedItemID:=al_sourceItemLB_IDs{$vl_RowNumber}
		  //SET TEXT TO PASTEBOARD($vl_selectedItemID)
		  //vl_draggedItemID:=$vl_selectedItemID
		
	: (Form event code:C388=On Losing Focus:K2:8)
		vb_sourceItemsLB_HasFocus:=False:C215
		
	: (Form event code:C388=On Getting Focus:K2:7)
		vb_sourceItemsLB_HasFocus:=True:C214
		
End case 
