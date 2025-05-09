extends State

## This value will be set by the state machine
var CHARACTER: Character
var OWNER: CurrentWeapon
var SM: SM_Weapon
var sm_name: SM_Weapon.States
var readable_name: String

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("a_attack") and SM.STATES[SM.S_ATTACK].can():
		SM.switch(SM.S_ATTACK)
			
	if Input.is_action_just_pressed("a_defend") and SM.STATES[SM.S_PARRY].can():
		SM.switch(SM.S_PARRY)
		
		#if weapon.PARRY_COOLDOWN_TIMER.is_stopped():
			#character_node.state_machine.switch_action_state(States.States.PARRY)
