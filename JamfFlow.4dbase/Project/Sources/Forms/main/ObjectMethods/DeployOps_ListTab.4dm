  // Change the visible options entry objects based on the deploy option selected. 

  // Load and clicked events

$vt_selected:=sh_arr_getCurrentValue (->at_DeployOps_ListTab)

OBJECT SET VISIBLE:C603(*;"deploy_jp_@";False:C215)
OBJECT SET VISIBLE:C603(*;"deploy_save_@";False:C215)
OBJECT SET VISIBLE:C603(*;"deploy_git_@";False:C215)

Case of 
		
	: ($vt_selected="Upload to Jamf Pro")
		OBJECT SET VISIBLE:C603(*;"deploy_jp_@";True:C214)
		OBJECT SET TITLE:C194(vl_Deploy_go_button;"Upload")
		
	: ($vt_selected="Save to disk")
		OBJECT SET VISIBLE:C603(*;"deploy_save_@";True:C214)
		OBJECT SET TITLE:C194(vl_Deploy_go_button;"Save")
		OBJECT SET COORDINATES:C1248(*;"deploy_save_EOLLabel";115;530)
		OBJECT SET COORDINATES:C1248(at_deploy_save_lineEndingPopup;226;526)
		
	: ($vt_selected="Git")
		OBJECT SET VISIBLE:C603(*;"deploy_git_@";True:C214)
		OBJECT SET COORDINATES:C1248(vl_deploy_git_saveLocalOnly_RB;75;524)
		OBJECT SET COORDINATES:C1248(vl_deploy_git_saveAndPush_RB;75;549)
		Case of 
			: (vl_deploy_git_saveLocalOnly_RB=1)
				OBJECT SET TITLE:C194(vl_Deploy_go_button;"Save")
			: (vl_deploy_git_saveAndPush_RB=1)
				OBJECT SET TITLE:C194(vl_Deploy_go_button;"Save & Push")
		End case 
		
End case 

