extends State

## This value will be set by the state machine
var OWNER: Character
var SM: SM_Character
var sm_name: SM_Character.States
var readable_name: String

func _physics_process(_delta: float) -> void:
	if OWNER.is_in_air():
		SM.switch(SM.S_IN_AIR)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(OWNER.CONTROLS.CROUCH):
		SM.switch(SM.S_IDLE)
		print('crouch0')

func enter_state():
	OWNER.speed = OWNER.CROUCH_SPEED
	OWNER.CROUCH_ANIMATION.play("crouch")
	OWNER.HEADBOB_ANIMATION.play('walk', 0.25)
	OWNER.HEADBOB_ANIMATION.speed_scale = 0.5
	
func exit_state():
	OWNER.CROUCH_ANIMATION.play_backwards("crouch")
