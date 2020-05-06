Case of 
	: (Form event code:C388=On Load:K2:1)
		ALL RECORDS:C47([Sets:1])
		REDRAW:C174(listBox_ManageSetsLIst)
		
	: (Form event code:C388=On Selection Change:K2:29)
		vt_manageXMLDisplay:=""
		
		$vl_SelectedManageSetItemsCount:=Records in set:C195("$set_ManageSetsListbox")
		Case of 
			: ($vl_SelectedManageSetItemsCount=0)
				REDUCE SELECTION:C351([XML:2];0)
			: ($vl_SelectedManageSetItemsCount=1)
				FIRST RECORD:C50([Sets:1])
				For ($i;1;Records in selection:C76([Sets:1]))
					If (Is in set:C273("$set_ManageSetsListbox"))
						QUERY:C277([XML:2];[XML:2]set_id:4=[Sets:1]ID:1)
						ORDER BY:C49([XML:2];[XML:2]ItemType:6;[XML:2]HumanReadableItemName:9)
						$i:=Records in selection:C76([Sets:1])+1
					End if 
					NEXT RECORD:C51([Sets:1])
				End for 
		End case 
		
End case 
