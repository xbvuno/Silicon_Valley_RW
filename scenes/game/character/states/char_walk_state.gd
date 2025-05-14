extends State

@export var STEP_SOUND_DELAY : float = .5 

## This value will be set by the state machine
var OWNER: Character
var SM: SM_Character
var sm_name: SM_Character.States
var readable_name: String
var timer : Timer

var sprint_already_pressed: bool = false

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = STEP_SOUND_DELAY
	timer.one_shot = true
	timer.autostart = false
	add_child(timer)
	super()

func _physics_process(_delta: float) -> void:
	
	if timer.is_stopped():
		print("step")
		OWNER.AUDIO_MANAGER.create_3d_audio_at_location(OWNER,SoundEffect.SOUND_EFFECT_TYPE.CHARACTER_STEP)
		timer.start()
	if OWNER.is_in_air():
		SM.switch(SM.S_IN_AIR)
		return
	
	if OWNER.get_input_moviment().is_zero_approx():
		SM.switch(SM.S_IDLE)
		return

	if sprint_already_pressed:
		if SM.STATES[SM.S_SPRINT].can():
			SM.switch(SM.S_SPRINT)
		sprint_already_pressed = false
	


func _input(event: InputEvent) -> void:
	if not OWNER.under_low_ceiling() and event.is_action_pressed(OWNER.CONTROLS.JUMP):
		SM.ACTIONS[SM.A_JUMP].do_jump()
		return
	
	if SM.STATES[SM.S_SPRINT].can() and event.is_action_pressed(OWNER.CONTROLS.SPRINT):
		SM.switch(SM.S_SPRINT)
		return
	
	if SM.STATES[SM.S_DASH].can_dash() and event.is_action_pressed(OWNER.CONTROLS.DASH):
		SM.switch(SM.S_DASH)
		return
	
	elif event.is_action_pressed(OWNER.CONTROLS.CROUCH):
		SM.switch(SM.S_CROUCH)

func enter_state():
	#if OWNER.sprint_enabled and Input.is_action_pressed(OWNER.CONTROLS.SPRINT):
		#SM.switch(SM.S_SPRINT)
		#return
	sprint_already_pressed = Input.is_action_pressed(OWNER.CONTROLS.SPRINT)
	OWNER.speed = OWNER.BASE_SPEED
	OWNER.HEADBOB_ANIMATION.play('walk', 0.25)
	
	
func exit_state():
	OWNER.HEADBOB_ANIMATION.speed_scale = 1
	OWNER.HEADBOB_ANIMATION.play("RESET", 1)
