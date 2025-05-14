extends State

## This value will be set by the state machine
var OWNER: Character
var SM: SM_Character
var sm_name: SM_Character.States
var readable_name: String


func _physics_process(_delta: float) -> void:
	
	if OWNER.is_on_floor():
		play_landing_animation()
		SM.ACTIONS[SM.A_JUMP].reset()
		SM.switch(SM.S_IDLE)


func _input(event: InputEvent) -> void:
	
	if SM.STATES[SM.S_DASH].can_dash() and event.is_action_pressed(OWNER.CONTROLS.DASH):
		SM.switch(SM.S_DASH)
		return
		
	if event.is_action_pressed(OWNER.CONTROLS.JUMP) and SM.ACTIONS[SM.A_JUMP].can_jump(true):
		SM.ACTIONS[SM.A_JUMP].do_jump(true)
		return


func play_landing_animation():
	var facing_direction : Vector3 = OWNER.CAMERA.get_global_transform().basis.x
	var facing_direction_2D : Vector2 = Vector2(facing_direction.x, facing_direction.z).normalized()
	var velocity_2D : Vector2 = Vector2( OWNER.velocity.x,  OWNER.velocity.z).normalized()

	# Compares velocity direction against the camera direction (via dot product) to determine which landing animation to play.
	var side_landed : int = round(velocity_2D.dot(facing_direction_2D))

	if side_landed > 0:
		OWNER.JUMP_ANIMATION.play("land_right", 0.25)
	elif side_landed < 0:
		OWNER.JUMP_ANIMATION.play("land_left", 0.25)
	else:
		OWNER.JUMP_ANIMATION.play("land_center", 0.25)
		

func enter_state():
	pass
	
func exit_state():
	pass
