Case of 
	: (Form event code:C388=On Load:K2:1)
		  //ARRAY BOOLEAN(ab_DeploySetsListBox;0)
		ALL RECORDS:C47([Sets:1])
		  //REDRAW(ab_DeploySetsListBox)
		
	: (Form event code:C388=On Selection Change:K2:29)
		  //$vl_SelectedManageSetItemsCount:=Records in set("$set_ManageSetsListbox")
		  //Case of 
		  //: ($vl_SelectedManageSetItemsCount=0)
		  //REDUCE SELECTION([XML];0)
		
		  //: ($vl_SelectedManageSetItemsCount=1)
		  //FIRST RECORD([Sets])
		  //For ($i;1;Records in selection([Sets]))
		  //If (Is in set("$set_ManageSetsListbox"))
		  //QUERY([XML];[XML]set_id=[Sets]ID)
		  //ORDER BY([XML];[XML]ItemType;[XML]SourceServerItemName)
		  //$i:=Records in selection([Sets])+1
		  //End if 
		  //NEXT RECORD([Sets])
		  //End for 
		
		  //End case 
		
End case 
