extends State

## This value will be set by the state machine
var OWNER: Character
var SM: SM_Character
var sm_name: SM_Character.States
var readable_name: String



func _physics_process(_delta: float) -> void:
	if OWNER.is_on_floor():
		SM.ACTIONS[SM.A_LAND].do_land()

func _input(event: InputEvent) -> void:
	if SM.STATES[SM.S_DASH].can_dash() and event.is_action_pressed(OWNER.CONTROLS.DASH):
		SM.switch(SM.S_DASH)
		return
		
	if event.is_action_pressed(OWNER.CONTROLS.JUMP) and SM.ACTIONS[SM.A_JUMP].can_jump(true):
		SM.ACTIONS[SM.A_JUMP].do_jump(true)
		return

func enter_state():
	pass
	
func exit_state():
	pass
