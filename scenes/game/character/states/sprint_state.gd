extends State
class_name CharacterSprintState

func _ready() -> void:
	super()
	state_name = States.States.SPRINTING

func _physics_process(_delta: float) -> void:
	# Se il personaggio rimane fermo
	if character_node.is_on_floor() and character_node.input_dir == Vector2.ZERO:
		character_node.state_machine.switch_movement_state(States.States.IDLE)
	
func _input(event: InputEvent) -> void:
	if character_node.is_on_floor() and event.is_action_pressed(character_node.CONTROLS.JUMP):
		if !character_node.low_ceiling:
			character_node.state_machine.switch_movement_state(States.States.JUMPING)

	if event.is_action_released(character_node.CONTROLS.SPRINT):
		character_node.state_machine.switch_movement_state(States.States.WALKING)
		
	if event.is_action_pressed(character_node.CONTROLS.CROUCH):
		character_node.state_machine.switch_movement_state(States.States.CROUCHING)

func enter_state():
	character_node.speed = character_node.SPRINT_SPEED
	
func exit_state():
	pass
