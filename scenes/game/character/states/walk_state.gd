extends State
class_name CharacterWalkState

func _ready() -> void:
	super()
	state_name = States.States.WALKING

func _physics_process(_delta: float) -> void:
	if character_node.sprint_enabled:
		if character_node.sprint_mode == 0:
			if character_node.is_on_floor() and character_node.input_dir == Vector2.ZERO:
				character_node.state_machine.switch_movement_state(States.States.IDLE)
	
func _input(event: InputEvent) -> void:
	if character_node.is_on_floor() and event.is_action_pressed(character_node.CONTROLS.JUMP):
		if !character_node.low_ceiling:
			character_node.state_machine.switch_movement_state(States.States.JUMPING)
	# Se il personaggio prova a sprintare
	if event.is_action_pressed(character_node.CONTROLS.SPRINT):
		character_node.state_machine.switch_movement_state(States.States.SPRINTING)
		
	if event.is_action_pressed(character_node.CONTROLS.CROUCH):
		character_node.state_machine.switch_movement_state(States.States.CROUCHING)
	

func enter_state():
	character_node.speed = character_node.BASE_SPEED
	if Input.is_action_pressed(character_node.CONTROLS.SPRINT):
		character_node.state_machine.switch_movement_state(States.States.SPRINTING)
	
func exit_state():
	pass
