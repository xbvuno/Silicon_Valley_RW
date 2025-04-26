extends State
class_name CharacterJumpState

func _ready() -> void:
	super()
	state_name = States.States.JUMPING

func _physics_process(_delta: float) -> void:
	# TODO: Pensare a un modo migliore che non implichi l'uso del dollaro.
	if character_node.is_double_tap and $"../DashState".can_dash():
		character_node.state_machine.switch_movement_state(States.States.DASHING)
		
	if character_node.is_on_floor():
		$"../AirJumpState".reset()
		character_node.state_machine.switch_movement_state(States.States.IDLE)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(character_node.CONTROLS.JUMP):
		# TODO: Pensare a un modo migliore che non implichi l'uso del dollaro.
		if $"../AirJumpState".can_air_jump():
			character_node.state_machine.switch_movement_state(States.States.AIR_JUMP)

func play_jump_animation():
	var facing_direction : Vector3 = character_node.CAMERA.get_global_transform().basis.x
	var facing_direction_2D : Vector2 = Vector2(facing_direction.x, facing_direction.z).normalized()
	var velocity_2D : Vector2 = Vector2( character_node.velocity.x,  character_node.velocity.z).normalized()

	# Compares velocity direction against the camera direction (via dot product) to determine which landing animation to play.
	var side_landed : int = round(velocity_2D.dot(facing_direction_2D))

	if side_landed > 0:
		character_node.JUMP_ANIMATION.play("land_right", 0.25)
	elif side_landed < 0:
		character_node.JUMP_ANIMATION.play("land_left", 0.25)
	else:
		character_node.JUMP_ANIMATION.play("land_center", 0.25)

func enter_state():
	character_node.JUMP_ANIMATION.play("jump", 0.25)
	character_node.velocity.y += character_node.JUMP_VELOCITY
	
func exit_state():
	play_jump_animation()
