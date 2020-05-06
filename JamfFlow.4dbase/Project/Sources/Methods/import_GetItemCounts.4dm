//%attributes = {}
  // import_GetItemCounts

If (vt_selectedItemsSummary>"")
	vt_selectedItemsSummary:=vt_selectedItemsSummary+<>CRLF
End if 
vt_selectedItemsSummary:=vt_selectedItemsSummary+"Current selection summary:"+<>CRLF

ARRAY TEXT:C222($at_selectedItemsSummary_types;0)
ARRAY LONGINT:C221($al_selectedItemsSummary_counts;0)
  // Loop through each item in the selected items list and count them up by type
For ($i;1;Size of array:C274(at_selectedItemsListBox_types))
	$vl_typeRowIndex:=Find in array:C230($at_selectedItemsSummary_types;at_selectedItemsListBox_types{$i})
	If ($vl_typeRowIndex=-1)  // Not found
		APPEND TO ARRAY:C911($at_selectedItemsSummary_types;at_selectedItemsListBox_types{$i})
		APPEND TO ARRAY:C911($al_selectedItemsSummary_counts;1)
	Else   // We already have a summary element for this type. Just ++ the count. 
		$al_selectedItemsSummary_counts{$vl_typeRowIndex}:=$al_selectedItemsSummary_counts{$vl_typeRowIndex}+1
	End if 
End for 

For ($i;1;Size of array:C274($at_selectedItemsSummary_types))
	$vl_Count:=$al_selectedItemsSummary_counts{$i}
	$vt_countString:=String:C10($vl_Count)
	$vl_countStringLen:=Length:C16($vt_countString)
	$vt_itemLabel:=sh_str_getSingularForm ($at_selectedItemsSummary_types{$i};$vl_Count)
	$vt_itemLabel:=Uppercase:C13($vt_itemLabel[[1]])+Substring:C12($vt_itemLabel;2)
	vt_selectedItemsSummary:=vt_selectedItemsSummary+(" "*(4-$vl_countStringLen))+$vt_countString+" : "+$vt_itemLabel+<>CRLF
End for 
  //Strip trailing carriage return...
vt_selectedItemsSummary:=Substring:C12(vt_selectedItemsSummary;1;Length:C16(vt_selectedItemsSummary)-1)
