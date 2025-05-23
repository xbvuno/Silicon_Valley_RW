extends State

## Sprint Enabled
@export var SPRINT_ENABLED: bool = true
## This value will be set by the state machine
var OWNER: Character
var SM: SM_Character
var sm_name: SM_Character.States
var readable_name: String

@export var STEP_SOUND_DELAY : float = .4
@onready var STEP_SOUND: AudioStreamPlayer3D = $"../../AudioSfx/StepSound"
var STEP_SOUND_TIMER : Timer

func _ready() -> void:
	STEP_SOUND_TIMER = Utils.timer_from_time(STEP_SOUND_DELAY,true,self)
	super()
	
func _physics_process(_delta: float) -> void:
	if STEP_SOUND_TIMER.is_stopped():
		STEP_SOUND.play()
		STEP_SOUND_TIMER.start()
	if OWNER.is_in_air():
		SM.switch(SM.S_IN_AIR)
		return
	
	if OWNER.get_input_moviment().is_zero_approx():
		SM.switch(SM.S_IDLE)
		return
	
func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed(OWNER.CONTROLS.JUMP) and SM.ACTIONS[SM.A_JUMP].can_jump():
		SM.ACTIONS[SM.A_JUMP].do_jump()
		return
		
	if SM.STATES[SM.S_DASH].can_dash() and event.is_action_pressed(OWNER.CONTROLS.DASH):
		SM.switch(SM.S_DASH)
		return

	if event.is_action_released(OWNER.CONTROLS.SPRINT):
		SM.switch(SM.S_WALK)

func can():
	return SPRINT_ENABLED

func enter_state():
	OWNER.speed = OWNER.SPRINT_SPEED
	OWNER.HEADBOB_ANIMATION.play('sprint', 0.25)
	OWNER.HEADBOB_ANIMATION.speed_scale = 2
	
func exit_state():
	OWNER.HEADBOB_ANIMATION.speed_scale = 1
	OWNER.HEADBOB_ANIMATION.play("RESET", 1)
