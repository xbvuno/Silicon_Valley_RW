extends Node

var OWNER: Character
var SM: SM_Character

## Air Jump enabled.
@export var AIR_JUMP_ENABLED: bool = true
## Jump Boost Multiplier.
@export var AIR_JUMP_BOOST: float = 1.4
## Time to wait from a jump to another
@export var JUMP_COOLDOWN_SEC: float = .1
## Max number of dashes in air you can do before touching ground
@export var MAX_AIR_JUMPS: int =  1


var JUMP_COOLDOWN_TIMER: Timer
var air_jumps: int = 0
var just_jumped_on_floor: bool = false

@onready var JUMP_SOUND: AudioStreamPlayer3D = $"../../../AudioSfx/JumpSound"
@onready var AIR_JUMP_SOUND: AudioStreamPlayer3D = $"../../../AudioSfx/AirJumpSound"



func should_considered_on_floor() -> bool:
	return not just_jumped_on_floor and OWNER.should_considered_on_floor()

func _ready():
	JUMP_COOLDOWN_TIMER = Utils.timer_from_time(JUMP_COOLDOWN_SEC, true, self)
	

func can_jump(in_air: bool = false) -> bool:
	if in_air and not should_considered_on_floor():
		if not AIR_JUMP_ENABLED:
			return false
		if air_jumps >= MAX_AIR_JUMPS:
			return false
		
	if OWNER.under_low_ceiling():
		return false
	
	return JUMP_COOLDOWN_TIMER.is_stopped()

func do_jump(in_air: bool = false):
	var multiply: float = 1
	if in_air and not should_considered_on_floor():
		multiply = AIR_JUMP_BOOST
		air_jumps += 1
		AIR_JUMP_SOUND.play()
	else:
		SM.switch(SM.S_IN_AIR)
		JUMP_SOUND.play()
		just_jumped_on_floor = true
	JUMP_COOLDOWN_TIMER.start()
	OWNER.velocity.y = OWNER.JUMP_VELOCITY * multiply
	OWNER.JUMP_ANIMATION.play("jump", 0.25)

func reset():
	just_jumped_on_floor = false
	air_jumps = 0
	
