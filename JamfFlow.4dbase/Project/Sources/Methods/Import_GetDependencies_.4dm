//%attributes = {}
  // Import_GetDependencies_

$vl_loopsSoFar:=$1

  // Make a copy of the things we want to check. 
  // We will be adding to the list as we go so we could get 
  //  into some wierd loops if something sorts the array while we're working
  //ARRAY TEXT(at_selectedItemsListBox_types)
  //ARRAY LONGINT(al_selectedItemsListBox_ids)
  //COPY ARRAY(at_selectedItemsListBox_types;$at_selectedItemsListBox_types)
  //COPY ARRAY(al_selectedItemsListBox_ids;$al_selectedItemsListBox_ids)

  // Loop through the items in the selected items list box, checking each for dependencies
  //$vl_SelectedItemsCount:=Size of array(at_selectedItemsListBox_types)

$vl_progressProcessRef:=Progress_New ("Calculating dependencies (Pass "+String:C10($vl_loopsSoFar)+")";470;100)

  //$vl_currentFormWindowRef:=Current form window
  //$vl_left:=10
  //$vl_top:=50
  //$vl_right:=0
  //$vl_bottom:=0
  //GET WINDOW RECT($vl_left;$vl_top;$vl_right;$vl_bottom;$vl_currentFormWindowRef)
  //$vl_progressProcessRef:=Progress New (False)
  //  //Progress SET WINDOW VISIBLE (False)
  //Progress SET WINDOW VISIBLE (True;$vl_left+470;$vl_top+100;True)
  //Progress SET FONT SIZES (13;11;13)
  //Progress SET TITLE ($vl_progressProcessRef;)
  //Progress SET BUTTON ENABLED ($vl_progressProcessRef;True)

$vb_goodToGo:=True:C214
$vl_countOfSelectedItems:=Size of array:C274(at_selectedItemsListBox_types)
For ($vl_selectedItemsIterator;1;$vl_countOfSelectedItems)
	
	
	$vt_selectedSourceServer:=at_SelectSourceServer{at_SelectSourceServer}  //What's our source server? 
	$vt_selectedItem_type:=at_selectedItemsListBox_types{$vl_selectedItemsIterator}
	$vl_selectedItem_id:=al_selectedItemsListBox_ids{$vl_selectedItemsIterator}
	$vt_selectedItem_Name:=at_selectedItemsListBox_names{$vl_selectedItemsIterator}
	$vt_selectedItem_servertypeid:=$vt_selectedSourceServer+"|"+$vt_selectedItem_type+"|"+String:C10($vl_selectedItem_id)
	
	Progress SET PROGRESS ($vl_progressProcessRef;$vl_selectedItemsIterator-1/$vl_countOfSelectedItems;"Evaluating "+$vt_selectedItem_type+", ID:"+String:C10($vl_selectedItem_id);False:C215)
	
	  // There are some cases where we'll be skipping the file. Some things aren't useful to scan. Or we may have scanned it previously. 
	$vl_postionInAlreadyCheckedList:=Find in array:C230(at_ImportDataTypesChecked;$vt_selectedItem_servertypeid)
	$vb_scanThisFile:=True:C214
	Case of 
		: ($vl_postionInAlreadyCheckedList>0)
			$vb_scanThisFile:=False:C215
			
		: ($vt_selectedItem_type="Computer reports")
			  // Ignore the thing below. Computer reports are just the output of advanced searches. 
			  // Usefull for data extracts but no put/post method so not something to consider for migrations. 
			  // There might be some point to saving them to the db, but I don't want to scan for dependencies. 
			$vb_scanThisFile:=False:C215
			vt_selectedItemsSummary:=vt_selectedItemsSummary+"[note] Skipping computer report "+sh_str_dq ($vt_selectedItem_Name)+"."+<>CRLF
	End case 
	
	If ($vb_scanThisFile)  // If we haven't checked this one yet...
		APPEND TO ARRAY:C911(at_ImportDataTypesChecked;$vt_selectedItem_servertypeid)  // Add it to the list of things we've already scanned
		  //
		  // Get the XML for the item
		  //
		C_OBJECT:C1216($vo_API_GetItemXML)
		$vo_API_GetItemXML:=API_GetItemXML ($vt_selectedSourceServer;$vt_selectedItem_type;$vl_selectedItem_id)
		  // Fetch info from response object...
		C_LONGINT:C283($vl_httpNetworkError)
		$vl_httpNetworkError:=$vo_API_GetItemXML.error
		C_TEXT:C284($vt_xml)
		$vt_xml:=$vo_API_GetItemXML.XML
		C_TEXT:C284($vt_url)
		$vt_url:=$vo_API_GetItemXML.URL
		C_LONGINT:C283($vl_httpStatusCode)
		$vl_httpStatusCode:=$vo_API_GetItemXML.httpStatusCode
		
		$vt_endpoint:=Replace string:C233($vt_url;$vt_selectedSourceServer;"")
		Case of 
			: ($vl_httpNetworkError=0)
				Case of 
					: ($vl_httpStatusCode#200)
						$vb_goodToGo:=False:C215
						vt_selectedItemsSummary:=vt_selectedItemsSummary+<>CRLF
						vt_selectedItemsSummary:=vt_selectedItemsSummary+"[error] HTTP Status : "+String:C10($vl_httpStatusCode)+<>CRLF
						vt_selectedItemsSummary:=vt_selectedItemsSummary+"Server: "+$vt_selectedSourceServer+<>CRLF
						vt_selectedItemsSummary:=vt_selectedItemsSummary+"Path  : "+$vt_endpoint+<>CRLF
						$vt_xml_noTags:=sh_html_stripTags ($vt_xml)
						vt_selectedItemsSummary:=vt_selectedItemsSummary+$vt_xml_noTags+<>CRLF
					: ($vt_xml="<html>@")
						$vb_goodToGo:=False:C215
						vt_selectedItemsSummary:=vt_selectedItemsSummary+<>CRLF
						vt_selectedItemsSummary:=vt_selectedItemsSummary+"[error] Call to "+$vt_url+" returned HTML:"+<>CRLF
						vt_selectedItemsSummary:=vt_selectedItemsSummary+"Server: "+$vt_selectedSourceServer+<>CRLF
						vt_selectedItemsSummary:=vt_selectedItemsSummary+"Path  : "+$vt_endpoint+<>CRLF
						$vt_xml_noTags:=sh_html_stripTags ($vt_xml)
						vt_selectedItemsSummary:=vt_selectedItemsSummary+$vt_xml_noTags+<>CRLF
					Else 
						  // vt_selectedItemsSummary:=vt_selectedItemsSummary+<>CRLF+$vt_url+" -> "+"HTTP Status : "+String($vl_httpStatusCode)+<>CRLF
						  // vt_selectedItemsSummary:=vt_selectedItemsSummary+"[ok] "+$vt_url+<>CRLF
				End case 
			: ($vl_httpNetworkError=30)
				vt_selectedItemsSummary:=vt_selectedItemsSummary+<>CRLF
				vt_selectedItemsSummary:=vt_selectedItemsSummary+"[error](30) Could not reach the server for "+$vt_selectedSourceServer+". Check network connection and host name."+<>CRLF
				$vb_goodToGo:=False:C215
			Else 
				vt_selectedItemsSummary:=vt_selectedItemsSummary+<>CRLF
				vt_selectedItemsSummary:=vt_selectedItemsSummary+"[error] API call to "+$vt_url+" returned a network error "+String:C10(vl_Error)+"."+<>CRLF
				$vb_goodToGo:=False:C215
		End case 
		
		If ($vb_goodToGo)
			  // Is there anything we need to prune before we scan for dependencies? 
			
			  // The device details included in advanced searches can be many megs of data. 
			  // It takes a long time to parse and there are no dependencies in there. 
			  // We can prune them, but we haven't converted to an XML object yet, 
			  //  so we'll jsut do it in text.
			Case of 
				: ($vt_selectedItem_type="Advanced computer searches")
					C_LONGINT:C283($vl_position_found1;$vl_position_found2;$vl_length_found)
					$vl_position_found1:=Position:C15("<computers>";$vt_xml)
					$vl_position_found2:=Position:C15("</computers>";$vt_xml)
					$vl_length_found:=$vl_position_found2-$vl_position_found1+12  // +12 to include "</computers>"
					If (($vl_position_found1>0) & ($vl_position_found2>0))
						$vt_xml:=Delete string:C232($vt_xml;$vl_position_found1;$vl_length_found)  // Buh bye
					End if 
				: ($vt_selectedItem_type="Advanced mobile device searches")
					C_LONGINT:C283($vl_position_found1;$vl_position_found2;$vl_length_found)
					$vl_position_found1:=Position:C15("<mobile_devices>";$vt_xml)
					$vl_position_found2:=Position:C15("</mobile_devices>";$vt_xml)
					$vl_length_found:=$vl_position_found2-$vl_position_found1+17  // +17 to include "</mobile_devices>"
					If (($vl_position_found1>0) & ($vl_position_found2>0))
						$vt_xml:=Delete string:C232($vt_xml;$vl_position_found1;$vl_length_found)
					End if 
			End case 
			
		End if   //If ($vb_goodToGo)
		
		If ($vb_goodToGo)
			  // Remove empty tags from XML. E.g.     <self_service_icon/>
			  // This can take a very long time for large amounts of data.
			  // E.g. /advanced_computer_search/computers
			$vt_xml:=sh_str_xml_strpEmtpyTags ($vt_xml)
		End if   //If ($vb_goodToGo)
		
		If ($vb_goodToGo)
			Case of 
				: ($vt_selectedItem_type="Computer reports")
					  // Ignore the thing below. Computer reports are just the output of advanced searches. 
					  // Usefull for data extracts but no put/post method so not something to consider for migrations. 
					  // There might be some point to saving them to the db, but I don't want to scan for dependencies. 
					$vb_scanThisFile:=False:C215
					vt_selectedItemsSummary:=vt_selectedItemsSummary+"[note] Skipping dependencies for Computer Report "+sh_str_dq ($vt_selectedItem_Name)+"."+<>CRLF
					
				: ($vt_selectedItem_type="Computer reports")
					  // Fix an issue that can cause the XML for computer reports to be unparsable
					  // If a computer advanced search is configured to include "Enrollment_Method: PreStage_enrollment" 
					  // under the display > export-only, /computerreports will contain <Enrollment_Method:_PreStage_enrollment> tags. 
					  // Similarly, if an extension attribute has a ":" in its name, /computerreports will include a tag that contains 
					  // a ":". An xml tag that has a ":" is unparsable. E.g.:
					  //-:1: namespace error : Namespace prefix Jamf_Protect on _Installation is not defi
					  //<Jamf_Protect:_Installation$vl_start:=1
					$vl_start:=1
					Repeat 
						$vb_found:=Match regex:C1019("<[^>]*:[^>]*>";$vt_xml;$vl_start;$vl_pos_found;$vl_length_found)
						If ($vb_found)
							If ($vl_pos_found=1)
								$vt_xml1:=""
							Else 
								$vt_xml1:=Substring:C12($vt_xml;1;$vl_pos_found-1)
							End if 
							$vt_xml2:=Substring:C12($vt_xml;$vl_pos_found;$vl_length_found)
							$vt_xml2:=Replace string:C233($vt_xml2;":";"")  // strip the ":"
							If (($vl_pos_found+$vl_length_found)=(Length:C16($vt_xml)))
								$vt_xml3:=""
							Else 
								$vt_xml3:=Substring:C12($vt_xml;$vl_pos_found+$vl_length_found)
							End if 
							$vt_xml:=$vt_xml1+$vt_xml2+$vt_xml3
							$start:=$vl_pos_found+$vl_length_found
						End if 
					Until (Not:C34($vb_found))
			End case 
		End if   //If ($vb_goodToGo)
		
		
		If ($vb_goodToGo & $vb_scanThisFile)
			  // Parse the XML
			C_TEXT:C284($vt_xmlRootElementReference)
			ON ERR CALL:C155("sh_err_call")
			$vt_xmlRootElementReference:=DOM Parse XML variable:C720($vt_xml)
			ON ERR CALL:C155("")
			If (vl_Error#0)  // Could not parse
				$vb_goodToGo:=False:C215
				vt_selectedItemsSummary:=vt_selectedItemsSummary+<>CRLF
				vt_selectedItemsSummary:=vt_selectedItemsSummary+"[error] I could not parse the XML for an item."+<>CRLF
				vt_selectedItemsSummary:=vt_selectedItemsSummary+"[url] "+$vt_url+<>CRLF
				vt_selectedItemsSummary:=vt_selectedItemsSummary+"[xml] -------------------------------------------"+<>CRLF+$vt_xml+<>CRLF+<>CRLF
			End if 
			
		End if 
		
		
		If ($vb_goodToGo & $vb_scanThisFile & (Not:C34(Progress Stopped ($vl_progressProcessRef))))
			  // Get a list of all the /id elements contained in the XML
			  // First init arrays to fill with dependancies
			ARRAY TEXT:C222(at_importSelectedID_Types;0)
			ARRAY LONGINT:C221(al_importSelectedID_IDs;0)
			ARRAY TEXT:C222(at_importSelectedID_Names;0)
			$vt_RootObjectInfo:=$vt_selectedItem_type+" "+$vt_selectedItem_Name+"("+String:C10($vl_selectedItem_id)+")"
			Import_Selected_GetIDs ($vt_xmlRootElementReference;$vt_RootObjectInfo)
			
			If ($vt_xmlRootElementReference#"00000000000000000000000000000000")
				DOM CLOSE XML:C722($vt_xmlRootElementReference)
			End if 
			
			  // Loop through all the encountered ID elements, adding each to our list of selected items as needed
			For ($id_Iterator;1;Size of array:C274(at_importSelectedID_Types))
				$vt_importSelectedID_Type:=at_importSelectedID_Types{$id_Iterator}
				$vl_importSelectedID_ID:=al_importSelectedID_IDs{$id_Iterator}
				$vt_importSelectedID_Name:=at_importSelectedID_Names{$id_Iterator}
				
				  // See if the item is already in the list of selected items
				$vb_itemIsAlreadySelected:=False:C215
				For ($vl_SelectedItemsListIterator;1;Size of array:C274(at_selectedItemsListBox_types))
					$vt_selectedItemsListBox_types:=at_selectedItemsListBox_types{$vl_SelectedItemsListIterator}
					$vl_selectedItemsListBox_ids:=al_selectedItemsListBox_ids{$vl_SelectedItemsListIterator}
					$vt_selectedItemsListBox_names:=at_selectedItemsListBox_names{$vl_SelectedItemsListIterator}
					If ($vt_selectedItemsListBox_types=$vt_importSelectedID_Type)
						If ($vl_selectedItemsListBox_ids=$vl_importSelectedID_ID)
							  // If ($vt_selectedItemsListBox_names=$vt_importSelectedID_Name)
							$vb_itemIsAlreadySelected:=True:C214
							$vl_SelectedItemsListIterator:=Size of array:C274(at_selectedItemsListBox_types)+1  // We found it. Pop the loop
							  // End if 
						End if 
					End if 
				End for   // For ($vl_SelectedItemsListIterator;1;Size of array(at_selectedItemsListBox_types))
				
				If (Not:C34($vb_itemIsAlreadySelected))
					APPEND TO ARRAY:C911(at_selectedItemsListBox_types;$vt_importSelectedID_Type)
					APPEND TO ARRAY:C911(al_selectedItemsListBox_ids;$vl_importSelectedID_ID)
					APPEND TO ARRAY:C911(at_selectedItemsListBox_names;$vt_importSelectedID_Name)
					
					vt_selectedItemsSummary:=vt_selectedItemsSummary+<>CRLF
					vt_selectedItemsSummary:=vt_selectedItemsSummary+"[+] "+$vt_importSelectedID_Type+<>CRLF
					vt_selectedItemsSummary:=vt_selectedItemsSummary+$vt_importSelectedID_Name+<>CRLF  // "ID="+sh_str_dq ($vl_importSelectedID_ID)+" Name="+sh_str_dq (
				End if 
			End for   // For ($id_Iterator;1;Size of array(importSelectedID_Types))
		End if   // If ($vb_errorDetected)
		
		CLEAR VARIABLE:C89(at_importSelectedID_Types)
		CLEAR VARIABLE:C89(al_importSelectedID_IDs)
		CLEAR VARIABLE:C89(at_importSelectedID_Names)
	End if   // if(find in array(at_ImportDataTypesChecked;$vt_selectedItem_type)>0)
	
	
	If (Not:C34($vb_goodToGo))
		sh_msg_Alert ("There was an issue checking for dependencies. Please check the summary box for details.")
		$vl_selectedItemsIterator:=Size of array:C274(at_selectedItemsListBox_types)  // pop the loop
	Else 
		If (Progress Stopped ($vl_progressProcessRef))
			$vl_selectedItemsIterator:=Size of array:C274(at_selectedItemsListBox_types)  // pop the loop
			$vb_goodToGo:=False:C215  // Tell the caller we're stopping
			vt_selectedItemsSummary:=vt_selectedItemsSummary+"[stop] User interrupted"+<>CRLF
		End if 
	End if 
	
End for   // For ($vl_selectedItemsIterator;1;Size of array(at_selectedItemsListBox_types))


MULTI SORT ARRAY:C718(at_selectedItemsListBox_types;>;at_selectedItemsListBox_names;>;al_selectedItemsListBox_ids;>)

Progress_Close ($vl_progressProcessRef)

$0:=$vb_goodToGo