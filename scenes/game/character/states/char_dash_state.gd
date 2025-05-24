extends State
class_name CharacterDashState

## This value will be set by the state machine
var OWNER: Character
var SM: SM_Character
var sm_name: SM_Character.States
var readable_name: String

## Dash enabled.
@export var ENABLED: bool = true
## Speed of the dash.
@export var SPEED: float = 30
## Duration of the dash in seconds: How fast the dash will be.
@export var DURATION_SEC: float = 0.3
## Cooldown of the dash in seconds: How long until the dash can be used again.
@export var COOLDOWN_SEC: float = 1.0
## Max number of dashes in air you can do before touching ground
@export var MAX_AIR_DASHES: int =  1

var DURATION_TIMER: Timer
var COOLDOWN_TIMER: Timer

var air_dashes: int = 0

@onready var dash_sound: AudioStreamPlayer3D = $"../../AudioSfx/DashSound"

func _ready() -> void:
	super()
	DURATION_TIMER = Utils.timer_from_time(DURATION_SEC, true, self, end_dash)
	COOLDOWN_TIMER = Utils.timer_from_time(COOLDOWN_SEC, true, self)

func can_dash() -> bool:
	if not ENABLED:
		return false
		
	if OWNER.is_on_floor() or OWNER.should_considered_on_floor():
		air_dashes = 0
	elif air_dashes >= MAX_AIR_DASHES:
		return false
		
	return COOLDOWN_TIMER.is_stopped()

func end_dash():
	if OWNER.is_on_floor():
		OWNER.SM.switch(SM.S_IDLE)
	else:
		OWNER.SM.switch(SM.S_IN_AIR)


func do_dash() -> void:
	var direction = OWNER.get_input_direction()
	var tw: Tween = OWNER.get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tw.tween_property(OWNER, "velocity", direction * SPEED, DURATION_SEC)
	DURATION_TIMER.start()
	if OWNER.is_in_air():
		air_dashes += 1
	
func enter_state():
	#OWNER.AUDIO_MANAGER.create_3d_audio_at_location(OWNER,SoundEffect.SOUND_EFFECT_TYPE.CHARACTER_DASH)
	dash_sound.play()
	OWNER.use_gravity(false)
	OWNER.use_accelleration(false)
	do_dash()
	
func exit_state():
	OWNER.use_gravity(true)
	OWNER.use_accelleration(true)
	COOLDOWN_TIMER.start()
