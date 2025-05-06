extends State
class_name CharacterIdleState

func _ready() -> void:
	super()
	state_name = States.States.IDLE

func _physics_process(_delta: float) -> void:
	# TODO: Pensare a un modo migliore che non implichi l'uso del dollaro.
	if character_node.velocity.y<0.0:
		character_node.state_machine.switch_movement_state(States.States.FALLING)
	if character_node.is_double_tap and $"../DashState".can_dash():
		character_node.state_machine.switch_movement_state(States.States.DASHING)
	
	if character_node.is_on_floor() and character_node.input_dir != Vector2.ZERO:
		character_node.state_machine.switch_movement_state(States.States.WALKING)
	if character_node.velocity.y<0:
		character_node.state_machine.switch_movement_state(States.States.FALLING)

	
func _input(event: InputEvent) -> void:
	if character_node.is_on_floor() and event.is_action_pressed(character_node.CONTROLS.JUMP):
		if !character_node.low_ceiling:
			character_node.state_machine.switch_movement_state(States.States.JUMPING)
	
	if event.is_action_pressed(character_node.CONTROLS.CROUCH):
		character_node.state_machine.switch_movement_state(States.States.CROUCHING)

func enter_state():
	character_node.speed = character_node.BASE_SPEED
	
func exit_state():
	pass
