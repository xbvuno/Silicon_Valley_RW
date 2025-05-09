extends State

## This value will be set by the state machine
var OWNER: Character
var SM: SM_Character
var sm_name: SM_Character.States
var readable_name: String

func _physics_process(_delta: float) -> void:
	
	if OWNER.is_in_air():
		SM.switch(SM.S_IN_AIR)
		return
	
	if not OWNER.get_input_moviment().is_zero_approx(): # TODO: Verificare il funzionamento rispetto a (v != Vector2.ZERO)
		SM.switch(SM.S_WALK)
	
	
func _input(event: InputEvent) -> void:
	if not OWNER.under_low_ceiling() and event.is_action_pressed(OWNER.CONTROLS.JUMP):
		SM.ACTIONS[SM.A_JUMP].do_jump()
		
	if Input.is_action_just_pressed(OWNER.CONTROLS.CROUCH):
		SM.switch(SM.S_CROUCH)
		#character_node.state_machine.switch_movement_state(States.States.CROUCHING)
	
	#if character_node.is_on_floor() and event.is_action_pressed(character_node.CONTROLS.JUMP):
		#if !character_node.low_ceiling:
			#character_node.state_machine.switch_movement_state(States.States.JUMPING)
	#
	#if event.is_action_pressed(character_node.CONTROLS.CROUCH):
		#character_node.state_machine.switch_movement_state(States.States.CROUCHING)

func enter_state():
	pass
	
func exit_state():
	pass
