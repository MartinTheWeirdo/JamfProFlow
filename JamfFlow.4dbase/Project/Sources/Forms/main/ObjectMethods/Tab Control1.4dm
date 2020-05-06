  // at_ImportSetOperations tab control

Case of 
	: (Form event code:C388=On Load:K2:1)
		OBJECT SET VISIBLE:C603(*;"ImportOps_Modify_@";False:C215)
		
	: (Form event code:C388=On Clicked:K2:4)
		  // We're going to show and hide objects to get the interface to match the selected option in the tab bar...
		Case of 
				
			: (at_ImportSetOperations=1)
				OBJECT SET TITLE:C194(*;"ImportSetOperationsButton";"Save New")
				OBJECT SET VISIBLE:C603(*;"ImportOps_NewSet_f1";True:C214)
				OBJECT SET VISIBLE:C603(*;"ImportOps_Modify_@";False:C215)
				
			: (at_ImportSetOperations=2)
				
				ALL RECORDS:C47([Sets:1])
				ORDER BY:C49([Sets:1];[Sets:1]Name:2)
				SELECTION TO ARRAY:C260([Sets:1]Name:2;at_ImportOps_SetListPopup)
				REDRAW:C174(at_ImportOps_SetListPopup)
				
				OBJECT SET TITLE:C194(*;"ImportSetOperationsButton";"Update")
				OBJECT SET VISIBLE:C603(*;"ImportOps_NewSet_f1";False:C215)
				OBJECT SET VISIBLE:C603(*;"ImportOps_Modify_@";True:C214)
				C_LONGINT:C283($vl_left;$vl_top;$vl_right;$vl_bottom)
				OBJECT GET COORDINATES:C663(*;"ImportOps_NewSet_f1";$vl_left;$vl_top;$vl_right;$vl_bottom)
				OBJECT SET COORDINATES:C1248(*;"ImportOps_Modify_Popup";$vl_left-2;$vl_top-2)
				
		End case 
End case 
