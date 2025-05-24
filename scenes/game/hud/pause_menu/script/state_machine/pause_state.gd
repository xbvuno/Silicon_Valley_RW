extends State

## This value will be set by the state machine
var OWNER: Control
var SM: SM_PAUSE_MENU
var sm_name: SM_PAUSE_MENU.States
var readable_name: String

func enter_state():
	OWNER.MAIN_MENU.visible = true
	
func exit_state():
	OWNER.MAIN_MENU.visible = false
