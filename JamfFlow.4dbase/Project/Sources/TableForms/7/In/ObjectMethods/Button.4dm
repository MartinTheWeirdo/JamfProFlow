  //$vt:=Request("Enter char...")
  //myAlert(String(Character code($vt)))

$pf:=OBJECT Get pointer:C1124(Object with focus:K67:3)  // Save the pointer to the last area
Case of 
	: (Is nil pointer:C315($pf))  // No object has the focus
		BEEP:C151
	: ((Type:C295($pf->)=Is alpha field:K8:1) | (Type:C295($pf->)=Is text:K8:3) | (Type:C295($pf->)=Is string var:K8:2))  // If it is a string or text area
		GET HIGHLIGHT:C209($pf->;$vl_startSel;$vl_endSel)
		$vt:=Substring:C12($pf->;$vl_startSel;1)
		sh_msg_Alert (String:C10(Character code:C91($vt)))
End case 
