extends State
class_name CharacterJumpState

func _ready() -> void:
	super()
	state_name = States.States.JUMPING

func _physics_process(_delta: float) -> void:
	# TODO: Pensare a un modo migliore che non implichi l'uso del dollaro.
	if character_node.is_double_tap and $"../DashState".can_dash():
		character_node.state_machine.switch_movement_state(States.States.DASHING)
		
	if character_node.is_on_floor() :
		$"../AirJumpState".reset()
		character_node.state_machine.switch_movement_state(States.States.IDLE)
	if character_node.velocity.y<0.0:
		character_node.state_machine.switch_movement_state(States.States.FALLING)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(character_node.CONTROLS.JUMP):
		# TODO: Pensare a un modo migliore che non implichi l'uso del dollaro.
		if $"../AirJumpState".can_air_jump():
			character_node.state_machine.switch_movement_state(States.States.AIR_JUMP)



func enter_state():
	character_node.JUMP_ANIMATION.play("jump", 0.25)
	$"../AirJumpState".start_timer()
	character_node.velocity.y = character_node.JUMP_VELOCITY
	
func exit_state():
	pass
	
