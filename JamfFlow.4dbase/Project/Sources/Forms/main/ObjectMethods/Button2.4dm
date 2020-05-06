  // Open highlighted item

$vt_link:=sh_arr_getCurrentValue (->at_DeployLinks_Links;ab_CreatedItemsListBox)
$vt_link:=at_DeployLinks_Links{ab_CreatedItemsListBox}
If ($vt_link#"")
	OPEN URL:C673($vt_link)
End if 
