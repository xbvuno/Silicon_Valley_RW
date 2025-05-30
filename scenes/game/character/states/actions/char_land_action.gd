extends Node

var OWNER: Character
var SM: SM_Character
var sm_name: SM_Character.Actions

@onready var LANDING_SOUND: AudioStreamPlayer3D = $"../../../AudioSfx/LandingSound"

func do_land():
	play_landing_animation()
	LANDING_SOUND.play()
	SM.ACTIONS[SM.A_JUMP].reset()
	SM.switch(SM.S_IDLE)
	SM.add_action_to_latest(sm_name)

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
		
