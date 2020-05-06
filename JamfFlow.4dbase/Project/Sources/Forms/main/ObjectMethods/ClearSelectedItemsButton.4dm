Case of 
	: (Form event code:C388=On Clicked:K2:4)
		
		$vb_userHasSelectedItems:=False:C215
		  // For ($i;0;Size of array(ab_selectedItemsListBox)-1)
		For ($i;Size of array:C274(ab_selectedItemsListBox);1;-1)  // Have to work backwards so we don't displace things before we get to them
			If (ab_selectedItemsListBox{$i})
				$vb_userHasSelectedItems:=True:C214
				DELETE FROM ARRAY:C228(ab_selectedItemsListBox;$i)
				DELETE FROM ARRAY:C228(at_selectedItemsListBox_types;$i)
				DELETE FROM ARRAY:C228(al_selectedItemsListBox_ids;$i)
				DELETE FROM ARRAY:C228(at_selectedItemsListBox_names;$i)
			End if 
		End for 
		
		If (Not:C34($vb_userHasSelectedItems))
			  // Nothing highlighted. Delete all
			ARRAY BOOLEAN:C223(ab_selectedItemsListBox;0)
			ARRAY TEXT:C222(at_selectedItemsListBox_types;0)
			ARRAY LONGINT:C221(al_selectedItemsListBox_ids;0)
			ARRAY TEXT:C222(at_selectedItemsListBox_names;0)
		End if 
		
End case 

vt_selectedItemsSummary:=""
import_GetItemCounts 
