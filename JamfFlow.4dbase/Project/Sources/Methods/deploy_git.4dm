//%attributes = {}
  // deploy_git

$vb_goodToGo:=True:C214

$vt_localRepoSystemPath:=git_get ("LocalRepoPathSystem")

$vb_goodToGo:=deploy_git_saveToLocalRepo ($vt_localRepoSystemPath)

  // Now we have saved the set(s) to the local git folder. Do we also want to push it to the git server? 
Case of 
	: (vl_deploy_git_saveLocalOnly_RB=1)
		  // No, we do not
		vt_deployedItemsSummary:=vt_deployedItemsSummary+<>CRLF+<>CRLF
		vt_deployedItemsSummary:=vt_deployedItemsSummary+"[done] Push to Git server was not requested. You can use your Git application or command line to sync changes to the server."
		
	: (vl_deploy_git_saveAndPush_RB=1)
		$vb_goodToGo:=deploy_git_push ($vt_localRepoSystemPath)
		
End case 

  // Update git status display box.
git_getSyncStatus 
BEEP:C151

$0:=$vb_goodToGo
